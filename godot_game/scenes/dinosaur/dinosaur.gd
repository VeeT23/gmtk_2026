extends CharacterBody3D

## Emitted when a position passed to set_target() has been reached.
signal target_reached

@export var speed: float = 5.0
@export var rotation_speed: float = 5.0
## Hard cap on sight distance. The detection Area3D defines the real shape;
## this just stops absurdly long rays if the area is huge.
@export var detection_radius: float = 50.0
@export var path_update_interval: float = 0.25
@export var walk_animation : String = "walk_animation"
@export var run_animation  : String = "run_animation"

@export_group("Wandering")
## Movement speed while patrolling. Usually slower than the chase speed.
@export var wander_speed : float = 2.5
## Group name of the Node3Ds to patrol between.
@export var wander_group : StringName = &"WanderTarget"
## Seconds to pause on arrival at a target, randomised between the two.
@export var wander_pause_min : float = 1.5
@export var wander_pause_max : float = 4.0
## Degrees per second the dino sweeps its head around while paused.
@export var scan_speed : float = 35.0
## Pick the next target at random instead of walking them in order.
@export var wander_randomly : bool = true
## If true, spotting the player cancels a target set via set_target().
@export var hunt_interrupts_set_target : bool = true

@export_group("Line of Sight")
## Optional. Assign a node placed at the dino's head to cast sight rays from.
## If left empty, head_offset is used instead.
@onready var head_node: Node3D = $head_node
## Local-space eye position, used when head_node is not assigned.
@export var head_offset : Vector3 = Vector3(0.0, 13.0, 3.0)
## Layers that block sight. World (1) + Obstruction (32) = 33.
@export_flags_3d_physics var sight_block_mask : int = 33
## How often (seconds) to re-check line of sight.
@export var los_check_interval : float = 0.15
## How long the dino keeps chasing after losing sight of the player.
@export var lose_sight_grace : float = 2.0
## Local-space points on the player that count as "visible" if any one is exposed.
@export var player_sample_offsets : Array[Vector3] = [
	Vector3(0.0, 1.6, 0.0), # head
	Vector3(0.0, 0.9, 0.0), # chest
	Vector3(0.0, 0.2, 0.0), # feet
]

enum State { IDLE, WANDER, HUNT, MOVE_TO_TARGET }
var current_state: State = State.IDLE
var previous_state: State = State.IDLE

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $dino/AnimationPlayer

@onready var kill_box : Area3D = $Killbox
## The vision cone. Proximity/FOV comes from this shape, sight comes from the raycasts.
@onready var detection_area : Area3D = $Area3D

var player: Node3D
var path_timer: float = 0.0
var los_timer: float = 0.0
var player_in_area: bool = false
var has_line_of_sight: bool = false
var last_seen_timer: float = 0.0
var last_known_position: Vector3 = Vector3.ZERO

var wander_targets: Array[Node3D] = []
var wander_index: int = -1
var wander_pause_timer: float = 0.0
var scan_direction: float = 1.0
var has_forced_target: bool = false

func _ready() -> void:
	add_to_group("Dinosaur")
	kill_box.body_entered.connect(_kill_box_entered)
	detection_area.body_entered.connect(_detection_body_entered)
	detection_area.body_exited.connect(_detection_body_exited)
	player = get_tree().current_scene.find_child("Player", true, false) as Node3D
	if player == null:
		push_error("Dinosaur Error: Could not find a node named 'Player' in the scene!")


	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0

	_collect_wander_targets()

## Grabs every patrol point in the group and starts with the closest one.
func _collect_wander_targets() -> void:
	wander_targets.clear()
	for node in get_tree().get_nodes_in_group(wander_group):
		if node is Node3D:
			wander_targets.append(node)

	if wander_targets.is_empty():
		push_warning("Dinosaur: no nodes found in group '%s', wandering disabled." % wander_group)
		return

	var closest := 0
	var closest_dist := INF
	for i in wander_targets.size():
		var d := global_position.distance_to(wander_targets[i].global_position)
		if d < closest_dist:
			closest_dist = d
			closest = i
	wander_index = closest
	_set_nav_target(wander_targets[wander_index].global_position)

## Picks the next patrol point, never the one we just left.
func _advance_wander_target() -> void:
	if wander_targets.size() <= 1:
		return

	if wander_randomly:
		var next := wander_index
		while next == wander_index:
			next = randi() % wander_targets.size()
		wander_index = next
	else:
		wander_index = (wander_index + 1) % wander_targets.size()

	_set_nav_target(wander_targets[wander_index].global_position)

func _set_nav_target(target : Vector3) -> void:
	target.y = global_position.y
	nav_agent.target_position = target

## Sends the dinosaur to a specific world position, overriding its wandering.
## Once it arrives it goes back to patrolling on its own.
func set_target(pos: Vector3) -> void:
	has_forced_target = true
	current_state = State.MOVE_TO_TARGET
	wander_pause_timer = 0.0
	_set_nav_target(pos)

## Drops a target set by set_target() and returns to normal wandering.
func clear_target() -> void:
	has_forced_target = false
	_collect_wander_targets()

## Instantly moves the dinosaur somewhere and forgets about the player,
## so it doesn't immediately re-aggro from across the map.
func teleport_to(pos: Vector3, look_rotation: Vector3 = Vector3.ZERO) -> void:
	velocity = Vector3.ZERO
	global_position = pos
	global_rotation = look_rotation

	player_in_area = false
	has_line_of_sight = false
	last_seen_timer = 0.0
	last_known_position = pos
	wander_pause_timer = 0.0
	path_timer = 0.0
	los_timer = los_check_interval

func _detection_body_entered(body : Node3D) -> void:
	if body == player:
		player_in_area = true

func _detection_body_exited(body : Node3D) -> void:
	if body == player:
		player_in_area = false

func _kill_box_entered(_body : Node3D):
	get_tree().current_scene.kill_player()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	_update_line_of_sight(delta)
	_update_state()

	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.WANDER:
			_process_wander(delta)
		State.MOVE_TO_TARGET:
			_process_move_to_target(delta)
		State.HUNT:
			_process_hunt(delta)
	move_and_slide()

func get_eye_position() -> Vector3:
	if head_node != null:
		return head_node.global_position
	return global_transform * head_offset

## Casts rays from the dino's head to several points on the player.
## Returns true if at least one point is unobstructed.
func _check_line_of_sight() -> bool:
	if player == null:
		return false

	var space := get_world_3d().direct_space_state
	var from := get_eye_position()

	for offset in player_sample_offsets:
		var to : Vector3 = player.global_position + offset
		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = sight_block_mask
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.exclude = [get_rid()]
		# Nothing blocking between the head and this point -> player is visible.
		if space.intersect_ray(query).is_empty():
			return true

	return false

func _update_line_of_sight(delta: float) -> void:
	los_timer -= delta
	if los_timer <= 0.0:
		los_timer = los_check_interval
		# Only bother raycasting while the player is actually inside the vision cone.
		var in_cone : bool = player_in_area and player != null \
			and global_position.distance_to(player.global_position) <= detection_radius
		has_line_of_sight = _check_line_of_sight() if in_cone else false

	if has_line_of_sight and player != null:
		last_seen_timer = lose_sight_grace
		last_known_position = player.global_position
	else:
		last_seen_timer = max(last_seen_timer - delta, 0.0)

func _update_state() -> void:
	previous_state = current_state

	# has_line_of_sight is only ever true while the player is inside the cone,
	# so this covers proximity + FOV + actual visibility.
	# Keep hunting briefly after losing sight so the dino doesn't stop dead.
	var wants_to_hunt : bool = player != null \
		and (has_line_of_sight or last_seen_timer > 0.0)

	if wants_to_hunt and (hunt_interrupts_set_target or not has_forced_target):
		has_forced_target = false
		current_state = State.HUNT
	elif has_forced_target:
		current_state = State.MOVE_TO_TARGET
	elif not wander_targets.is_empty():
		current_state = State.WANDER
	else:
		current_state = State.IDLE

	# Coming out of a chase, resume the patrol from wherever we ended up.
	if current_state == State.WANDER and previous_state == State.HUNT:
		wander_pause_timer = randf_range(wander_pause_min, wander_pause_max)
		_advance_wander_target()

func _stop_moving() -> void:
	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)

func _play_animation(anim : String) -> void:
	if anim != "" and anim_player.has_animation(anim) \
		and anim_player.current_animation != anim:
		anim_player.play(anim)

## Follows the current nav path. Returns false once there's nowhere left to go.
func _follow_path(delta: float, move_speed: float) -> bool:
	if nav_agent.is_navigation_finished():
		_stop_moving()
		return false

	var next_point : Vector3 = nav_agent.get_next_path_position()
	var direction : Vector3 = (next_point - global_transform.origin).normalized()

	if direction.length_squared() > 0.001:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		var target_rotation := atan2(direction.x, direction.z)
		rotation.y = rotate_toward(rotation.y, target_rotation, rotation_speed * delta)
	return true

func _process_idle(delta: float) -> void:
	_stop_moving()
	_scan_around(delta)

## Sweeps the vision cone left and right so a stationary dino still feels alert.
func _scan_around(delta: float) -> void:
	rotation.y += deg_to_rad(scan_speed) * scan_direction * delta
	if randf() < 0.4 * delta:
		scan_direction *= -1.0

func _process_wander(delta: float) -> void:
	# Pause and look around at each waypoint before moving on.
	if wander_pause_timer > 0.0:
		wander_pause_timer -= delta
		_stop_moving()
		_scan_around(delta)
		if wander_pause_timer <= 0.0:
			_set_nav_target(wander_targets[wander_index].global_position)
		return

	_play_animation(walk_animation)

	if not _follow_path(delta, wander_speed):
		# Arrived. Rest here, then head for the next point.
		wander_pause_timer = randf_range(wander_pause_min, wander_pause_max)
		_advance_wander_target()

## Walks to a position handed in via set_target(), then resumes wandering.
func _process_move_to_target(delta: float) -> void:
	_play_animation(walk_animation)

	if not _follow_path(delta, wander_speed):
		target_reached.emit()
		has_forced_target = false
		_collect_wander_targets()
		wander_pause_timer = randf_range(wander_pause_min, wander_pause_max)

func _process_hunt(delta: float) -> void:
	wander_pause_timer = 0.0
	path_timer -= delta
	if path_timer <= 0.0:
		# If the player is hidden, head for where they were last seen.
		_set_nav_target(player.global_position if has_line_of_sight else last_known_position)
		path_timer = path_update_interval

	_play_animation(run_animation if run_animation != "" else walk_animation)
	_follow_path(delta, speed)


func _stomp():
	print("stomp")
