extends Node3D

@export var return_speed := 12.0
@export var max_angle := 10.0

var target_rot := Vector2.ZERO

func add_mouse_motion(mouse_delta: Vector2):
	target_rot.x += mouse_delta.y * 0.002
	target_rot.y += mouse_delta.x * 0.002

	target_rot.x = clamp(target_rot.x, deg_to_rad(-max_angle), deg_to_rad(max_angle))
	target_rot.y = clamp(target_rot.y, deg_to_rad(-max_angle), deg_to_rad(max_angle))

func _process(delta):
	target_rot = target_rot.lerp(Vector2.ZERO, 1.0 - exp(-return_speed * delta))

	rotation.x = target_rot.x
	rotation.y = target_rot.y
