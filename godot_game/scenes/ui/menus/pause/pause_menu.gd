extends CanvasLayer

@onready var ui: Control = $UI
@onready var resume_button: Button = $UI/VBoxContainer/ResumeButton
@onready var quit_button: Button = $UI/VBoxContainer/QuitButton

var paused = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ui.visible = false
	resume_button.press_finished.connect(_on_resume_pressed)
	quit_button.press_finished.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	paused = !paused
	if paused:
		get_tree().paused = true
		ui.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		get_tree().paused = false
		ui.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_quit_pressed() -> void:
	get_tree().quit()
