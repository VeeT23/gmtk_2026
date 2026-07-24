@tool
extends Node3D

const FENCE_WIDTH := 10.0
const FENCE_SCENE := preload("res://scenes/main/world/fence/fence.tscn")

@onready var target_radius_node: Node3D = $Target

@export_tool_button("Generate Corral")
var generate_corral_button: Callable = Callable(self, "create_corral")


func _ready():
	print("Editor:", Engine.is_editor_hint())
	if Engine.is_editor_hint():
		create_corral()

func create_corral() -> void:
	if !is_instance_valid(target_radius_node):
		return
	
	var radius := global_position.distance_to(target_radius_node.global_position)
	var center := global_position
	
	for child in get_children():
		if child != target_radius_node:
			child.queue_free()
	
	var circumference := TAU * radius
	var fence_count : int= max(3, roundi(circumference / FENCE_WIDTH))
	var angle_step := TAU / fence_count
	
	for i in range(fence_count):
		var angle := i * angle_step
		
		var fence := FENCE_SCENE.instantiate()
		add_child(fence)
		fence.owner = owner # Makes the fence persist in the scene.
		
		fence.position = Vector3( cos(angle) * radius ,0.0, sin(angle) * radius)
		
		fence.look_at(center, Vector3.UP)
		fence.rotate_y(-PI * 0.5)
