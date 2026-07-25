extends CharacterBody3D

@export var speed: float = 5.0
@export var rotation_speed: float = 5.0
@export var detection_radius: float = 50.0
@export var path_update_interval: float = 0.25
@export var walk_animation : String = "DinosaurArmature|WalkAnimation"
@export var run_animation  : String = "DinosaurArmature|RunAnimation"

enum State { IDLE, HUNT }
var current_state: State = State.IDLE

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $dino/AnimationPlayer

@onready var kill_box : Area3D = $Killbox

var player: Node3D
var path_timer: float = 0.0

func _ready() -> void:
	kill_box.body_entered.connect(_kill_box_entered)
	player = get_tree().current_scene.find_child("Player", true, false) as Node3D
	if player == null:
		push_error("Dinosaur Error: Could not find a node named 'Player' in the scene!")
	
	
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0

func _kill_box_entered(_body : Node3D):
	get_tree().current_scene.kill_player()

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

func _process_idle(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)

func _process_hunt(delta: float) -> void:
	path_timer -= delta
	if path_timer <= 0.0:
		var target = player.global_position
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
