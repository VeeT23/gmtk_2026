extends Node3D

@onready var c_interactable : Interactable = $ComputerInteractable
@onready var r_interactable : Interactable = $RadioInteractable

func _ready() -> void:
	c_interactable.interacted.connect(_on_computer_interact)
	r_interactable.interacted.connect(_on_radio_interact)
	GameState.game_state_changed.connect(_on_state_change)
	$monitor/pc_monitor_mp_1.get_active_material(1).emission_enabled = false

func _on_state_change(flag : String, value : Variant):
	if flag == "fueled_generator" and value == true:
		c_interactable.action = "(Needs spare parts)"
		r_interactable.action = "(Repair computer to broadcast)"
	elif flag == "collected_electronics" and value == true:
		c_interactable.action = "Press [E] to repair"
	elif flag == "repaired_computer" and value == true:
		r_interactable.action = "Press [E] to broadcast"

func _on_computer_interact():
	if GameState.game_state["collected_electronics"] and GameState.game_state["fueled_generator"]:
		GameState.change_state("repaired_computer", true)
		$monitor/pc_monitor_mp_1.get_active_material(1).emission_enabled = true

		c_interactable.disable()

func _on_radio_interact():
	if GameState.game_state["repaired_computer"] and GameState.game_state["fueled_generator"]:
		GameState.change_state("sent_distress_signal", true)
		r_interactable.disable()
