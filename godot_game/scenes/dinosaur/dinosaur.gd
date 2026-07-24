extends CharacterBody3D

@export var speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var detection_radius: float = 15.0
@export var path_update_interval: float = 0.25

enum State { IDLE, HUNT }
var current_state: State = State.IDLE

var player: Node3D
var nav_agent: NavigationAgent3D
var path_timer: float = 0.0

func _ready() -> void:
	$dino/AnimationPlayer.play("newwalk")

	player = get_tree().current_scene.find_child("Player", true, false) as Node3D
	if player == null:
		push_error("Dinosaur Error: Could not find a node named 'Player' in the scene!")
	else:
		print("Dinosaur: player found -> ", player.name)

	nav_agent = $NavigationAgent3D
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0

	# Wait a frame so the NavigationServer has synced the baked navmesh
	await get_tree().physics_frame
	print("Dinosaur: nav map = ", nav_agent.get_navigation_map())


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	_update_state()

	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.HUNT:
			_process_hunt(delta)

	move_and_slide()


func _update_state() -> void:
	if player == null:
		current_state = State.IDLE
		return

	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	current_state = State.HUNT if dist <= detection_radius else State.IDLE


func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)


func _process_hunt(delta: float) -> void:
	path_timer -= delta
	if path_timer <= 0.0:
		nav_agent.target_position = player.global_transform.origin
		path_timer = path_update_interval
		# DEBUG - remove once working
		print("Dinosaur: target set, path finished? ", nav_agent.is_navigation_finished(),
			" path len: ", nav_agent.get_current_navigation_path().size())

	if nav_agent.is_navigation_finished():
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		return

	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_transform.origin)
	direction.y = 0
	direction = direction.normalized()

	if direction.length_squared() > 0.001:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = rotate_toward(rotation.y, target_rotation, rotation_speed * delta)
