extends CharacterBody3D
const BASE_SPEED = 3.0
const SPRINT_SPEED = 6.0
const BASE_FOV = 75.0
const SPRINT_FOV = 90.0
const FOV_CHANGE_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

const BOB_FREQ_WALK = 2.0
const BOB_FREQ_SPRINT = 3.2
const BOB_AMP = 0.06

const FOOTSTEP_SOUNDS : = [
	preload("res://assets/sfx/interaction/Footstep.mp3"),
	preload("res://assets/sfx/interaction/Footstep2.mp3"),
	preload("res://assets/sfx/interaction/Footstep3.mp3")
]


@onready var camera : Camera3D = $Camera3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight
@onready var footstep_player : AudioStreamPlayer = $FootstepSound
@onready var crouch_collider = $Crouching
@onready var standing_collider = $Standing
@export var camera_crouch_position = Vector3(0,0.9,0)
@export var camera_stand_position = Vector3(0,1.7,0)

var camera_pitch := 0.0
var is_crouching := false
var bob_time := 0.0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
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
	if velocity.length() > 0.1 and is_on_floor():
		if !footstep_player.playing and FOOTSTEP_SOUNDS.size():
			footstep_player.stream = FOOTSTEP_SOUNDS[randi_range(0, FOOTSTEP_SOUNDS.size() - 1)]
			footstep_player.play()
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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

	# Head bob - only advance the bob cycle while actually moving on the ground
	var is_moving = direction != Vector3.ZERO and is_on_floor()
	if is_moving:
		var bob_freq = BOB_FREQ_SPRINT if is_sprinting else BOB_FREQ_WALK
		bob_time += delta * bob_freq
	else:
		bob_time = 0.0

	var bob_offset = sin(bob_time * TAU) * BOB_AMP if is_moving else 0.0
	var base_y = camera_crouch_position.y if is_crouching else camera_stand_position.y
	camera.position.y = lerp(camera.position.y, base_y + bob_offset, 10.0 * delta)

	move_and_slide()
	
