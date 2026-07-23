extends Label

func _process(delta: float) -> void:
	var time_left = max(GameState.time_remaining, 0.0)
	
	if time_left >= 60.0:
		var minutes = int(time_left) / 60
		var seconds = int(time_left) % 60
		text = "%02d:%02d" % [minutes, seconds]
	else:
		var seconds = int(time_left)
		var centiseconds = int((time_left - seconds) * 100)
		text = "%02d:%02d" % [seconds, centiseconds]
