extends Node3D

@onready var lights : Node3D = $Lights
@onready var door_collision : StaticBody3D = $Door
@onready var door_animator : AnimationPlayer = $warehouse_mx_2/door_hr_9/AnimationPlayer

func _ready() -> void:
	GameState.game_state_changed.connect(_on_state_change)

func _on_state_change(flag : String, value : Variant) -> void:
	if flag == "fueled_generator" and value == true:
		_turn_lights_on()
	if flag == "cut_lock" and value == true:
		_open_door()

func _turn_lights_on() -> void:
	for light in lights.get_children():
		light.get_node("lamp_on").visible = true
		light.get_node("lamp_off").visible = false

func _open_door() -> void:
	door_collision.get_node("CollisionShape3D").disabled = true
	door_animator.play("door_open")
