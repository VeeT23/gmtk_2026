class_name Interactable
extends Area3D

@export var outlined_meshes: Array[MeshInstance3D]
@export var tooltip : String
@export var action : String

signal hover_entered
signal hover_exited
signal interacted

func _ready() -> void:
	if outlined_meshes.is_empty():
		push_warning("[Interactable:%s] No outlined meshes assigned." % name)
		
	for i in outlined_meshes.size():
		var mesh = outlined_meshes[i]
		
		if mesh == null:
			push_error("[Interactable:%s] outlined_meshes[%d] is null." % [name, i])

func _set_shaders(toggle : bool) -> void:
	for mesh in outlined_meshes:
		
		if mesh == null:
			continue
		if mesh.material_overlay == null:
			push_error("[Interactable:%s] Mesh '%s' has no material overlay." % [name, mesh.name])
			continue
		
		mesh.set_instance_shader_parameter("enabled", toggle)

func hover_enter() -> void:
	hover_entered.emit()
	_set_shaders(true)

func hover_exit() -> void:
	hover_exited.emit()
	_set_shaders(false)

func interact() -> void:
	interacted.emit()
	
	if !hover_entered.has_connections():
		push_error("[Interactable:%s] hover_entered has no listeners." % name)
