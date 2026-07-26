extends Node2D



func _ready() -> void:
	$AudioStreamPlayer.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/WinMenu/VBoxContainer/Control/CustomButton.press_finished.connect(_on_press)
	for child in $Confetti.get_children() as Array[GPUParticles2D]:
		child.set_emitting(true)

func _on_press():
	OS.shell_open("https://spatial-studio.itch.io/gmtk-2026")
	get_tree().change_scene_to_file("res://scenes/ui/menus/main/menu_scene.tscn")
