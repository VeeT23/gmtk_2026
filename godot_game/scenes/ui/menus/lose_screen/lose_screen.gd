extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$ColorRect.show()
	$ColorRect/AnimationPlayer.play("new_animation")
	$VBoxContainer/Retry.button_up.connect(_restart)
	$VBoxContainer/Quit.button_up.connect(_quit)

func _restart():
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _quit():
	OS.shell_open("https://spatial-studio.itch.io/gmtk-2026")
	get_tree().quit()
