extends Node3D

@onready var interactable : Interactable = $GasCanInteractable

func _ready() -> void:
	interactable.interacted.connect(_on_collect)
	interactable.sfx_finished.connect(_sfx_finished)

func _on_collect():
	GameState.change_state("collected_fuel", true)
	GameState.queue_dialog("takes_fuel")
	$jerrycan_mx_1.visible = false

func _sfx_finished():
	queue_free()
