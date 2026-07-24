extends Node3D

@onready var interactable : Interactable = $BoltCutterInteractable

func _ready() -> void:
	interactable.interacted.connect(_on_collect)
	interactable.sfx_finished.connect(_on_sfx_finished)

func _on_collect():
	GameState.change_state("collected_bolt_cutters", true)
	$BoltCutters.visible = false

func _on_sfx_finished():
	queue_free()
