extends Node

const TIME_SECONDS = 900

var is_player_dead := false

var timer : Timer = null
var time_remaining : float = 0.0

var game_state : Dictionary = {
	"game_started": false,
	"passed_bush": false,
	"collected_fuel" : false,
	"fueled_generator" : false,
	"collected_bolt_cutters" : false,
	"cut_lock" : false,
	"collected_electronics" : false,
	"repaired_computer" : false,
	"sent_distress_signal" : false
}

var voice_lines = {
	"game_start":[
		"God dammit... Those cowards left without me.",
		"Must've thought I was dead... Can't blame them, I guess.",
		"Whatever, easy solution: I'll just broadcast them a distress signal.",
		"First things first: get into the radio equipment shelter."
	],
	"sees_door":[
		"Great... Locked.",
		"Maintenance probably has something to cut it with.",
		"Should be on the map. [Press TAB or M to open map]",
		"...",
		"The whole \"Let's nuke the rampant dinosaurs!\" plan was stupid anyways.",
		"Not as stupid as missing the entire evac because of the runs.",
		"Stupid."
	],
	"walked_by_bush":[
		"Groundskeeper really needs to cut back these bushes.",
		"Eh, Im not complaining. Bushes like these make good hiding spots."
	],
	"takes_bolt_cutters":[
		"Just what the doctor ordered."
	],
	"cuts_lock":[
		"Great, time for power."
	],
	"sees_generator":[
		"No fuel... Fun.",
		"There's a fuel depot south from here. Would be silly if there wasn't fuel there."
	],
	"takes_fuel":[
		"Smells great."
	],
	"fuels_generator":[
		"Now to broadcast."
	],
	"sees_computer":[
		"\"Needs spare parts\"? This is just cheap writing!",
		"Anyways, visitor center. You get the idea."
	],
	"takes_parts":[
		"Finally, the last thing."
	],
	"repairs_computer":[
		"Time to broadcast..."
	],
}

var narration_label = null

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

func queue_dialog(dialog_key: String) -> void:
	if narration_label == null:
		narration_label = get_tree().get_first_node_in_group("NarrationLabel")
	print(dialog_key)
	if narration_label:
		narration_label.queue_dialogue(voice_lines[dialog_key])
