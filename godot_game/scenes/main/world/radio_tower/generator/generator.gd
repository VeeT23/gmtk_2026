extends Node3D

@onready var interactable : Interactable = $GeneratorInteractable
@onready var pour_player : AudioStreamPlayer = $PourSFXPlayer
@onready var hum_player : AudioStreamPlayer3D = $HumSFXPlayer

@export var hum_begin : AudioStream
@export var hum_loop : AudioStream

var _is_hum_looping := false

func _ready() -> void:
	interactable.interacted.connect(_on_interact)
	GameState.game_state_changed.connect(_on_state_change)
	pour_player.finished.connect(_on_pour_finished)
	hum_player.finished.connect(_on_hum_finished)

func _on_state_change(flag : String, value : Variant):
	if flag == "collected_fuel" and value == true:
		interactable.action = "Press [E] to refuel"

func _on_interact():
	if GameState.game_state["collected_fuel"]:
		GameState.change_state("fueled_generator", true)
		interactable.disable()
		$PourSFXPlayer.play()

func _on_pour_finished():
	hum_player.stream = hum_begin
	hum_player.play()

func _on_hum_finished():
	if !_is_hum_looping:
		hum_player.stream = hum_loop
		_is_hum_looping = true
	hum_player.play()
