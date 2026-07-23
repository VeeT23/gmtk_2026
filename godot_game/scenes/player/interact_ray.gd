class_name InteractRay
extends RayCast3D

var last_target_body = null
var target_body : Interactable = null

func _physics_process(_delta: float) -> void:
	var collider = get_collider()
	
	if collider != null and !(collider is Interactable):
		push_error("[InteractRay] Hit '%s' but it isn't an Interactable." % collider.name)
		collider = null 
	
	target_body = collider
	if target_body != last_target_body:
		if last_target_body:
			last_target_body.hover_exit()
			_update_interact_label("", "")
		if target_body:
			target_body.hover_enter()
			_update_interact_label(target_body.tooltip, target_body.action)
		
		last_target_body = target_body

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		if target_body != null:
			target_body.interact()

func _update_interact_label(tooltip : String, action : String):
	var label = get_tree().get_first_node_in_group("InteractLabel")
	if label:
		label.get_node("Tooltip").text = tooltip
		label.get_node("Action").text = action
