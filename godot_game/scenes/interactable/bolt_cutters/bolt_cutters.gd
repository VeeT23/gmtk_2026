extends Node3D

@onready var interactable : Interactable = $BoltCutterInteractable

func _ready() -> void:
	interactable.interacted.connect(_on_collect)

func _on_collect():
	GameState.change_state("collected_bolt_cutters", true)
	queue_free()
