extends Node2D

const VOTE_URL := "https://spatial-studio.itch.io/gmtk-2026"


func _ready() -> void:
	# Make sure nothing here can be swallowed by an earlier failure, and that a
	# missing node degrades instead of taking the whole screen down with it.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var audio := get_node_or_null("AudioStreamPlayer") as AudioStreamPlayer
	if audio != null:
		audio.play()

	var button := get_node_or_null(
		"CanvasLayer/WinMenu/VBoxContainer/Control/CustomButton"
	)
	if button != null and button.has_signal("press_finished"):
		button.press_finished.connect(_on_press)
	else:
		push_warning("WinScreen: vote button not found.")

	_start_confetti()


func _start_confetti() -> void:
	var confetti := get_node_or_null("Confetti")
	if confetti == null:
		return
	# Plain loop with a type check - casting get_children() to a typed array
	# throws at runtime, which killed everything after it in release builds.
	for child in confetti.get_children():
		if child is GPUParticles2D:
			child.emitting = true


func _on_press() -> void:
	OS.shell_open(VOTE_URL)
	get_tree().change_scene_to_file("res://scenes/ui/menus/main/menu_scene.tscn")
