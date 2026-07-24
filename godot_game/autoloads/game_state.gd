extends Node

const TIME_SECONDS = 600


var timer : Timer = null
var time_remaining : float = 0.0

var game_state : Dictionary = {
	"collected_fuel" : false,
	"fueled_generator" : false,
	"collected_bolt_cutters" : false,
	"cut_lock" : false,
	"collected_electronics" : false,
	"repaired_computer" : false,
	"sent_distress_signal" : false
}

# Fired every time game_state changes
signal game_state_changed(flag : String, value : Variant)

func change_state(flag : String, value : Variant) -> void:
	var old_value = game_state[flag]
	if old_value != value:
		game_state[flag] = value
		game_state_changed.emit(flag, value)

func begin_countdown():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(TIME_SECONDS)

func _process(_delta: float) -> void:
	if timer:
		time_remaining = timer.time_left
