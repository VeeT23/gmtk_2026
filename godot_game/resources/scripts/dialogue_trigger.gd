extends Area3D

@export var dialogue_key : String

func _ready() -> void:
	body_entered.connect(func(_body): GameState.queue_dialog(dialogue_key))
