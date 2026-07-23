extends Node3D

@onready var interactable : Interactable = $GeneratorInteractable

func _ready() -> void:
	interactable.interacted.connect(_on_interact)
	GameState.game_state_changed.connect(_on_state_change)

func _on_state_change(flag : String, value : Variant):
	if flag == "collected_fuel" and value == true:
		interactable.action = "Press [E] to refuel"

func _on_interact():
	if GameState.game_state["collected_fuel"]:
		GameState.change_state("fueled_generator", true)
		interactable.get_node("CollisionShape3D").disabled = true
