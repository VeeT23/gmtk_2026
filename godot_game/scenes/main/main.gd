extends Node

func _ready() -> void:
	GameState.begin_countdown()
	GameState.queue_dialog("game_start")
