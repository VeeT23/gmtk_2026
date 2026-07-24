extends Button

@onready var hover_stream = $HoverSound
@onready var click_stream = $ClickSound

var base_text := ""
var has_mouse : bool = false

signal press_finished()

func _ready() -> void:
	base_text = text
	mouse_entered.connect(func():
		hover_stream.play(0.02)
		has_mouse = true
		text = "> "+base_text+" <")
	
	mouse_exited.connect(func():
		has_mouse = false
		text = base_text)
	
	button_up.connect(func():
		if click_stream.stream == null:
			press_finished.emit()
			return
		click_stream.play()
		)
	
	click_stream.finished.connect(func():
		if has_mouse:
			press_finished.emit()
		)
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
		
