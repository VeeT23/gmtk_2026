extends Control

const METER_PER_PIXEL := 0.52
const MAP_OFFSET_METERS := Vector2(19.0,-0.5)


var is_shown := false
var player : CharacterBody3D = null

@onready var mat = $MarginContainer/TextureRect.material as ShaderMaterial

func _ready():
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		if is_shown:
			hide()
			is_shown = false
		else:
			show()
			is_shown = true

func _physics_process(_delta: float) -> void:
	if !player:
		player = get_tree().get_first_node_in_group("Player")
	else:
		var player_pos_2d := Vector2(player.global_position.x, player.global_position.z) - MAP_OFFSET_METERS
		var map_pos = player_pos_2d / (METER_PER_PIXEL * 1000)
		var map_uv = Vector2(map_pos.x + 0.5, map_pos.y + 0.5)
		mat.set_shader_parameter("circle_position", map_uv)
