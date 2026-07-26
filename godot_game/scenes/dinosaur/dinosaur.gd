extends CharacterBody3D

@export var speed: float = 5.0
@export var rotation_speed: float = 5.0
## Hard cap on sight distance. The detection Area3D defines the real shape;
## this just stops absurdly long rays if the area is huge.
@export var detection_radius: float = 50.0
@export var path_update_interval: float = 0.25
@export var walk_animation : String = "DinosaurArmature|WalkAnimation"
@export var run_animation  : String = "DinosaurArmature|RunAnimation"

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

enum State { IDLE, HUNT }
var current_state: State = State.IDLE

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
	if player == null:
		current_state = State.IDLE
		return

	# has_line_of_sight is only ever true while the player is inside the cone,
	# so this covers proximity + FOV + actual visibility.
	# Keep hunting briefly after losing sight so the dino doesn't stop dead.
	current_state = State.HUNT if (has_line_of_sight or last_seen_timer > 0.0) else State.IDLE

func _process_idle(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)

func _process_hunt(delta: float) -> void:
	path_timer -= delta
	if path_timer <= 0.0:
		# If the player is hidden, head for where they were last seen.
		var target = player.global_position if has_line_of_sight else last_known_position
		target.y = global_position.y
		nav_agent.target_position = target
		path_timer = path_update_interval

	if nav_agent.is_navigation_finished():
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		#if anim_player.current_animation != "idle":
		#	anim_player.play("idle")
		return
	
	if anim_player.current_animation != walk_animation:
		anim_player.play(walk_animation)
	
	var next_point = nav_agent.get_next_path_position()
	
	var direction = (next_point - global_transform.origin)
	direction = direction.normalized()
	
	if direction.length_squared() > 0.001:
		velocity = direction * speed
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = rotate_toward(rotation.y, target_rotation, rotation_speed * delta)
