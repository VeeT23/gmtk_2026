extends Area3D

@export var key : String
@export var act_trigger : bool
@export var on_exit : bool

func _ready() -> void:
	var sig : Signal = body_exited if on_exit else body_entered
	if act_trigger:
		sig.connect(func(_body): get_tree().current_scene.act_trigger(key))
	else:
		sig.connect(func(_body): GameState.queue_dialog(key))
