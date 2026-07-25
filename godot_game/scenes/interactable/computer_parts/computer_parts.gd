extends Node3D

@onready var interactable : Interactable = $PartsInteractable

func _ready() -> void:
	interactable.interacted.connect(_on_collect)
	interactable.sfx_finished.connect(_sfx_finished)

func _on_collect():
	GameState.change_state("collected_electronics", true)
	GameState.queue_dialog("takes_parts")
	visible = false

func _sfx_finished():
	queue_free()
