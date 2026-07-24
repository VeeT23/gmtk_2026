extends Node3D

@onready var door_interactable : Interactable = $DoorInteractable
@onready var garage_door_interactable : Interactable = $GarageDoorInteractable
@onready var door_physics : StaticBody3D = $Door
@onready var garage_door_physics : StaticBody3D = $GarageDoor

func _ready() -> void:
	door_interactable.interacted.connect(_on_door)
	garage_door_interactable.interacted.connect(_on_garage_door)

func _on_door():
	door_physics.get_node("Collider").disabled = true
	$warehouse_mx_4/DoorAnimator.play("open_door")

func _on_garage_door():
	garage_door_physics.get_node("Collider").disabled = true
	$warehouse_mx_4/GarageDoorAnimator.play("open_door")
