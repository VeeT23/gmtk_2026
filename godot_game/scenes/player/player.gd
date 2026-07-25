extends CharacterBody3D


const BASE_SPEED = 3.0
const SPRINT_SPEED = 6.0

const BASE_FOV = 75.0
const SPRINT_FOV = 90.0
const FOV_CHANGE_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

@onready var camera : Camera3D = $Camera3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight
@onready var crouch_collider = $Crouching
@onready var standing_collider = $Standing

@export var camera_crouch_position = Vector3(0,0.9,0)
@export var camera_stand_position = Vector3(0,1.7,0)
@export var footstep_sounds: Array[AudioStream] = []
@export var step_interval: float = 0.4
var step_timer: float = 0.0

var camera_pitch := 0.0
var is_crouching := false 
var footsteps_can_play:= true 
var footsteps_landed

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		# Left/right rotates the player
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Up/down rotates the camera
		camera_pitch -= event.relative.y * MOUSE_SENSITIVITY
		camera_pitch = clamp(camera_pitch, deg_to_rad(-89), deg_to_rad(89))
		camera.rotation.x = camera_pitch
		flashlight.add_mouse_motion(event.relative)
	elif event.is_action_pressed("crouch"):
		var tween = create_tween()
		tween.tween_property(camera, "position", camera_crouch_position, 0.2)
		is_crouching = true
		standing_collider.disabled = true
		crouch_collider.disabled = false
		
	elif event.is_action_released("crouch"):
		var tween = create_tween()
		tween.tween_property(camera, "position", camera_stand_position, 0.2)
		is_crouching = false
		standing_collider.disabled = false
		crouch_collider.disabled = true
	elif event.is_action_released("flashlight"):
		flashlight.visible = !flashlight.visible

func _physics_process(delta: float) -> void:
	
	#footsteps
	if velocity.length() > 0.1:
		step_timer -= delta
		if step_timer <= 0.0:
			$FootstepSound.stream = footstep_sounds[randi() % footstep_sounds.size()]
			$FootstepSound.play()
			step_timer = step_interval
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	footsteps_landed = is_on_floor()
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Movement relative to where the player is facing
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var is_sprinting := Input.is_action_pressed("sprint")
	var speed := (SPRINT_SPEED if is_sprinting else BASE_SPEED) * (0.5 if is_crouching else 1.0)
	
	var target_fov := SPRINT_FOV if is_sprinting else BASE_FOV
	camera.fov = lerp(camera.fov, target_fov, FOV_CHANGE_SPEED * delta)
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
