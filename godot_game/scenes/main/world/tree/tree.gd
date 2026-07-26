extends StaticBody3D

const TREE_SCENES := [
	preload("res://assets/terrain/foliage/trees/tree_5.glb"),
	preload("res://assets/terrain/foliage/trees/tree_6.glb"),
	preload("res://assets/terrain/foliage/trees/tree_7.glb")
]

const TREE_SHAKE_AMP := 10.0          # Base shake angle (degrees)
const TREE_SHAKE_TIME := 0.12         # Time to lean
const TREE_SHAKE_RETURN := 0.25       # Time to spring back
const TREE_SHAKE_RANDOM := 2.5        # Random shake variation (degrees)

const TREE_FALL_ANGLE := 85.0         # Maximum fall angle
const TREE_FALL_TIME := 1.2           # Fall duration
const TREE_FALL_RANDOM := 6.0         # Random fall angle variation
const TREE_FALL_TWIST := 8.0          # Random Y-axis twist while falling

const TREE_STIFFNESS := 1.0           # Multiplier for shake amount
const TREE_BOUNCE := 0.1              # Small bounce after landing (0 disables)
const TREE_RECOVER := true            # Return upright after rustling

const TREE_SHAKE_TRANS := Tween.TRANS_SINE
const TREE_SHAKE_EASE := Tween.EASE_OUT
const TREE_RETURN_TRANS := Tween.TRANS_SINE
const TREE_RETURN_EASE := Tween.EASE_IN_OUT

const TREE_FALL_TRANS := Tween.TRANS_EXPO
const TREE_FALL_EASE := Tween.EASE_IN

const TREE_USE_BODY_DIRECTION := true     # Fall away from body
const TREE_IGNORE_Y := true               # Ignore vertical difference
const TREE_MIN_PUSH := 0.5                # Minimum influence
const TREE_MAX_PUSH := 1.5                # Maximum influence

const TREE_RANDOM_SCALE := 0.15           # ±15% shake/fall variation
const TREE_RANDOM_SPEED := 0.2            # ±20% tween speed variation
const TREE_RANDOM_DELAY := 0.05           # Small reaction delay

@onready var rustle_detector = $RustleDetect
@onready var break_detector = $BreakDetect
@onready var mesh_root = $Mesh

var _is_broken := false

func _ready() -> void:
	_setup_mesh()
	rustle_detector.body_entered.connect(_rustle)
	break_detector.body_entered.connect(_break)

func _setup_mesh():
	var tree: Node3D = TREE_SCENES[randi_range(0, TREE_SCENES.size() - 1)].instantiate()
	mesh_root.add_child(tree)

	var scale_factor = randf_range(2.0, 3.2)
	tree.scale = Vector3.ONE * scale_factor
	tree.rotate_y(randf() * TAU)

func _rustle(body):
	if _is_broken:
		return

	_shake_away(body)

func _break(body):
	if _is_broken:
		return

	_is_broken = true
	_fall_away(body)

func _shake_away(body: Node3D) -> void:
	var away := global_position - body.global_position

	if TREE_IGNORE_Y:
		away.y = 0.0

	away = away.normalized()

	var strength := randf_range(TREE_MIN_PUSH, TREE_MAX_PUSH)
	strength *= randf_range(1.0 - TREE_RANDOM_SCALE, 1.0 + TREE_RANDOM_SCALE)

	var tilt := Vector3(
		deg_to_rad(away.z * TREE_SHAKE_AMP * TREE_STIFFNESS * strength),
		0.0,
		deg_to_rad(-away.x * TREE_SHAKE_AMP * TREE_STIFFNESS * strength)
	)

	tilt.x += deg_to_rad(randf_range(-TREE_SHAKE_RANDOM, TREE_SHAKE_RANDOM))
	tilt.z += deg_to_rad(randf_range(-TREE_SHAKE_RANDOM, TREE_SHAKE_RANDOM))

	var tween := create_tween()

	if TREE_RANDOM_DELAY > 0.0:
		tween.tween_interval(randf() * TREE_RANDOM_DELAY)

	var shake_time := TREE_SHAKE_TIME * randf_range(1.0 - TREE_RANDOM_SPEED, 1.0 + TREE_RANDOM_SPEED)
	var return_time := TREE_SHAKE_RETURN * randf_range(1.0 - TREE_RANDOM_SPEED, 1.0 + TREE_RANDOM_SPEED)

	tween.tween_property(mesh_root, "rotation", tilt, shake_time)\
		.set_trans(TREE_SHAKE_TRANS)\
		.set_ease(TREE_SHAKE_EASE)

	if TREE_RECOVER:
		tween.tween_property(mesh_root, "rotation", Vector3.ZERO, return_time)\
			.set_trans(TREE_RETURN_TRANS)\
			.set_ease(TREE_RETURN_EASE)

func _fall_away(body: Node3D) -> void:
	var away := global_position - body.global_position

	if TREE_IGNORE_Y:
		away.y = 0.0

	away = away.normalized()

	var strength := randf_range(TREE_MIN_PUSH, TREE_MAX_PUSH)
	strength *= randf_range(1.0 - TREE_RANDOM_SCALE, 1.0 + TREE_RANDOM_SCALE)

	var angle := (TREE_FALL_ANGLE + randf_range(-TREE_FALL_RANDOM, TREE_FALL_RANDOM)) * strength

	var final_rotation := Vector3(
		deg_to_rad(away.z * angle),
		mesh_root.rotation.y + deg_to_rad(randf_range(-TREE_FALL_TWIST, TREE_FALL_TWIST)),
		deg_to_rad(-away.x * angle)
	)

	var tween := create_tween()

	if TREE_RANDOM_DELAY > 0.0:
		tween.tween_interval(randf() * TREE_RANDOM_DELAY)

	var fall_time := TREE_FALL_TIME * randf_range(1.0 - TREE_RANDOM_SPEED, 1.0 + TREE_RANDOM_SPEED)

	tween.tween_property(mesh_root, "rotation", final_rotation, fall_time)\
		.set_trans(TREE_FALL_TRANS)\
		.set_ease(TREE_FALL_EASE)

	if TREE_BOUNCE > 0.0:
		var bounce := final_rotation * (1.0 - TREE_BOUNCE)

		tween.tween_property(mesh_root, "rotation", bounce, 0.15)\
			.set_trans(Tween.TRANS_BOUNCE)\
			.set_ease(Tween.EASE_OUT)

		tween.tween_property(mesh_root, "rotation", final_rotation, 0.1)
