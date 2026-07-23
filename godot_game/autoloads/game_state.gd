extends Node

const TIME_SECONDS = 600


var timer : Timer = null
var time_remaining : float = 0.0


func begin_countdown():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(TIME_SECONDS)

func _process(delta: float) -> void:
	if timer:
		time_remaining = timer.time_left
