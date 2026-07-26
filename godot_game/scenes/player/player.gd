extends CharacterBody3D
const BASE_SPEED = 3.0
const SPRINT_SPEED = 6.0
const BASE_FOV = 75.0
const SPRINT_FOV = 90.0
const FOV_CHANGE_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

const MAX_STAMINA = 8.0 # Seconds of sprinting

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
@onready var breathing_player : AudioStreamPlayer = $BreathingSound
@onready var crouch_collider = $Crouching
@onready var standing_collider = $Standing
@export var camera_crouch_position = Vector3(0,0.9,0)
@export var camera_stand_position = Vector3(0,1.7,0)

@export_group("Dinosaur Shake")
## Distance at which the screen shake starts being felt.
@export var shake_start_distance := 35.0
## Distance at which the shake reaches full strength.
@export var shake_full_distance := 8.0
## Maximum camera offset in metres.
@export var shake_max_offset := 0.09
## Maximum camera roll in degrees.
@export var shake_max_roll := 1.4
## How fast the shake vibrates.
@export var shake_speed := 22.0

var camera_pitch := 0.0
var is_crouching := false
var bob_time := 0.0
var stamina = MAX_STAMINA

var camera_base_y := 0.0
var shake_strength := 0.0
var shake_time := 0.0
var shake_noise := FastNoiseLite.new()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_base_y = camera_stand_position.y
	shake_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	shake_noise.frequency = 0.6
	shake_noise.seed = randi()

func _input(event):
	if GameState.is_player_dead:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pitch -= event.relative.y * MOUSE_SENSITIVITY
		camera_pitch = clamp(camera_pitch, deg_to_rad(-89), deg_to_rad(89))
		camera.rotation.x = camera_pitch
		flashlight.add_mouse_motion(event.relative)
	elif event.is_action_pressed("crouch"):
		# Height is smoothed toward the target in _physics_process (no tween, so it
		# doesn't fight the head bob / shake offsets also writing to camera.position).
		is_crouching = true
		standing_collider.disabled = true
		crouch_collider.disabled = false
	elif event.is_action_released("crouch"):
		is_crouching = false
		standing_collider.disabled = false
		crouch_collider.disabled = true
	elif event.is_action_released("flashlight"):
		flashlight.visible = !flashlight.visible

func _physics_process(delta: float) -> void:
	if GameState.is_player_dead:
		return
	#footsteps
	if velocity.length() > 0.1 and is_on_floor():
		if !footstep_player.playing and FOOTSTEP_SOUNDS.size():
			footstep_player.stream = FOOTSTEP_SOUNDS[randi_range(0, FOOTSTEP_SOUNDS.size() - 1)]
			footstep_player.play()
	
	breathing_player.volume_db = -25.0 * (stamina / MAX_STAMINA) + 10.0
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var pressing_sprint := Input.is_action_pressed("sprint") 
	
	if !pressing_sprint:
		stamina = min(stamina + delta, MAX_STAMINA)
	
	var is_sprinting : bool = pressing_sprint and stamina > 0.0
	
	if is_sprinting:
		stamina -= delta
	
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
	camera_base_y = lerp(camera_base_y, base_y + bob_offset, 10.0 * delta)

	_update_shake(delta)

	move_and_slide()


## Shakes the camera harder the closer the nearest dinosaur gets.
func _update_shake(delta: float) -> void:
	var nearest := INF
	for dino in get_tree().get_nodes_in_group("Dinosaur"):
		if dino is Node3D:
			nearest = min(nearest, global_position.distance_to(dino.global_position))

	var target_strength := 0.0
	if nearest < INF:
		target_strength = clampf(
			inverse_lerp(shake_start_distance, shake_full_distance, nearest), 0.0, 1.0
		)
		# Ease in so distant rumble stays subtle and close range hits hard.
		target_strength = target_strength * target_strength

	shake_strength = lerp(shake_strength, target_strength, 4.0 * delta)
	shake_time += delta * shake_speed

	if shake_strength < 0.001:
		camera.position = Vector3(0.0, camera_base_y, 0.0)
		camera.rotation.z = 0.0
		return

	var amount := shake_strength * shake_max_offset
	var offset := Vector3(
		shake_noise.get_noise_2d(shake_time, 0.0) * amount,
		shake_noise.get_noise_2d(shake_time, 100.0) * amount,
		shake_noise.get_noise_2d(shake_time, 200.0) * amount
	)

	camera.position = Vector3(offset.x, camera_base_y + offset.y, offset.z)
	camera.rotation.z = deg_to_rad(
		shake_noise.get_noise_2d(shake_time, 300.0) * shake_max_roll * shake_strength
	)
