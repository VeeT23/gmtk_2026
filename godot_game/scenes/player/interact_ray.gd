class_name InteractRay
extends RayCast3D

var last_target_body = null
var target_body = null

func _physics_process(_delta: float) -> void:
	var collider = get_collider()
	
	if collider != null and !(collider is Interactable):
		push_error("[InteractRay] Hit '%s' but it isn't an Interactable." % collider.name)
		collider = null 
	
	target_body = collider
	if target_body != last_target_body:
		if last_target_body:
			last_target_body.hover_exit()
		if target_body:
			target_body.hover_enter()
		
		last_target_body = target_body

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		if target_body != null:
			target_body.interact()
