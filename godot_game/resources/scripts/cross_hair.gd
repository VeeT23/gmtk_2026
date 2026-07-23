extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("rect_size", get_size())


func _on_resized() -> void:
	material.set_shader_parameter("rect_size", get_size())
