extends Control


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

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	$VBoxContainer.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_press():
	get_tree().current_scene.respawn_player()
