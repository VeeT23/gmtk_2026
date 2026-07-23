extends CanvasLayer

@onready var ui: Control = $UI
@onready var resume_button: Button = $UI/VBoxContainer/ResumeButton
@onready var quit_button: Button = $UI/VBoxContainer/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ui.visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	ui.visible = get_tree().paused

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_quit_pressed() -> void:
	get_tree().quit()
