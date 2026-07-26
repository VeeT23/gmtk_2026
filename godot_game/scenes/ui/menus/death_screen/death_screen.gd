extends Control

var transition_overlay : Control = null

func _ready() -> void:
	$VBoxContainer/CustomButton.press_finished.connect(_on_press)
	$ColorRect.color.a = 0
	$VBoxContainer.hide()

func hide_death_screen():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$ColorRect.color.a = 0
	hide()
	$VBoxContainer.hide()

func show_death_screen():
	$ColorRect.color.a = 0
	show()
	$AnimationPlayer.play("fade_in")

func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	$VBoxContainer.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_press():
	
	if !transition_overlay:
		transition_overlay = get_tree().current_scene.get_node("Canvas/UI/Transition")
		transition_overlay.fade_out_finished.connect(_fade_out_finished)
	
	$VBoxContainer.hide()
	transition_overlay.fade_out()


func _fade_out_finished():
	if !GameState.game_state["sent_distress_signal"] and GameState.is_player_dead:
		get_tree().current_scene.respawn_player()
