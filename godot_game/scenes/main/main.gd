extends Node

func _ready() -> void:
	GameState.begin_countdown()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("debug"):
		pass
