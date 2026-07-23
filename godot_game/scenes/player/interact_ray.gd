class_name InteractRay
extends RayCast3D

var current_target: Interactable = null

func _physics_process(_delta: float) -> void:
	var collider := get_collider()
	
	if collider != null and !(collider is Interactable):
		collider = null
	
	if collider != current_target:
		_set_target(collider)


func _set_target(new_target: Interactable) -> void:
	if current_target == new_target:
		return
	
	if is_instance_valid(current_target):
		if current_target.tree_exiting.is_connected(_on_target_removed):
			current_target.tree_exiting.disconnect(_on_target_removed)
		
		current_target.hover_exit()
		
	current_target = new_target
	
	if is_instance_valid(current_target):
		current_target.tree_exiting.connect(_on_target_removed)
		current_target.hover_enter()
		_update_interact_label(current_target.tooltip, current_target.action)
	else:
		_update_interact_label("", "")


func _on_target_removed() -> void:
	if is_instance_valid(current_target) and current_target.tree_exiting.is_connected(_on_target_removed):
		current_target.tree_exiting.disconnect(_on_target_removed)
	
	current_target = null
	_update_interact_label("", "")



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("interact") and is_instance_valid(current_target):
		current_target.interact()


func _update_interact_label(tooltip: String, action: String) -> void:
	var label := get_tree().get_first_node_in_group("InteractLabel")

	if label:
		label.get_node("Tooltip").text = tooltip
		label.get_node("Action").text = action
