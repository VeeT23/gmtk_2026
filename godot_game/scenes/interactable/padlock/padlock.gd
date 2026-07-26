extends RigidBody3D

@onready var interactable : Interactable = $LockInteractable

var looked_at := false

func _ready() -> void:
	interactable.interacted.connect(_on_use)
	interactable.hover_entered.connect(_on_hover)
	GameState.game_state_changed.connect(_on_state_change)

func _on_hover():
	if !looked_at:
		GameState.queue_dialog("sees_door")
		looked_at = true

func _on_state_change(flag : String, value : Variant):
	if flag == "collected_bolt_cutters" and value == true:
		interactable.action = "Press [E] to cut"
		interactable.set_sfx(load("res://assets/sfx/interaction/DoorUnlockFIX.mp3"))
func _on_use():
	if GameState.game_state["collected_bolt_cutters"]:
		GameState.change_state("cut_lock", true)
		freeze = false
		interactable.disable()
