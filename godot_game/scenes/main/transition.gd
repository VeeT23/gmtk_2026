extends Control

@onready var animator : AnimationPlayer = $AnimationPlayer

signal fade_in_finished
signal fade_out_finished

func _finished(animation):
	if animation == "fade_in":
		fade_in_finished.emit()
	elif animation == "fade_out":
		fade_out_finished.emit()

func _ready() -> void:
	# Other scripts reach this via get_first_node_in_group("Transition").
	add_to_group("Transition")
	$ColorRect.color.a = 1.0
	animator.animation_finished.connect(_finished)
	fade_in()

func fade_in():
	animator.play("fade_in")
	print("Fading in")
func fade_out():
	animator.play("fade_out")
	print("Fading out")
