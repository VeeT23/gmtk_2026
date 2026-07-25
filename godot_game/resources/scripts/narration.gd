extends Label

@export var character_delay := 0.03
@export var comma_pause := 0.12
@export var sentence_pause := 0.35
@export var ellipsis_pause := 0.7
@export var line_pause := 1.8

var dialogue_buffer: Array[String] = []
var _processing := false


func queue_dialogue(lines: Array) -> void:
	dialogue_buffer.append_array(lines)

	if !_processing:
		_process_buffer()


func _process_buffer() -> void:
	_processing = true

	while !dialogue_buffer.is_empty():
		var line: String = dialogue_buffer.pop_front()
		await _type_line(line)
		await get_tree().create_timer(line_pause,false, false, false).timeout

	text = ""
	_processing = false


func _type_line(line: String) -> void:
	text = ""
	
	var i := 0
	while i < line.length():
	
		# Handle ...
		if i + 2 < line.length() and line.substr(i, 3) == "...":
			text += "..."
			await get_tree().create_timer(character_delay + ellipsis_pause,false, false, false).timeout
			i += 3
			continue
		
		var c := line[i]
		text += c
		
		var delay := character_delay
		
		match c:
			'.', '!', '?':
				delay += sentence_pause
			',':
				delay += comma_pause
		
		await get_tree().create_timer(delay).timeout
		i += 1
