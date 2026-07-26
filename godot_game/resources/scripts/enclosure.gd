@tool
extends Node3D

const FENCE_WIDTH := 10.0
const FENCE_SCENE := preload("res://scenes/main/world/fence/fence.tscn")

const BUSH_SCENE := preload("res://scenes/main/world/hiding_spots/hiding_bush.tscn")

const TREE_SCENES := [
	preload("res://scenes/main/world/tree/tree.tscn")
]

const TREE_DENSITY := 0.02
const TREE_MIN_DISTANCE := 8.0
const BUSH_DENSITY := 0.01 # Bushes per square unit
const BUSH_MIN_DISTANCE := 4.0

@onready var target_radius_node: Node3D = $Target

@export_tool_button("Generate Corral")
var generate_corral_button: Callable = Callable(self, "create_corral")


func _ready():
	if Engine.is_editor_hint():
		create_corral()


func create_corral() -> void:
	if !is_instance_valid(target_radius_node):
		return

	var radius := global_position.distance_to(target_radius_node.global_position)
	var center := global_position

	for child in get_children():
		if child != target_radius_node:
			child.queue_free()

	# Generate fence
	var circumference := TAU * radius
	var fence_count : int = max(3, roundi(circumference / FENCE_WIDTH))
	var angle_step := TAU / fence_count

	for i in range(fence_count):
		var angle := i * angle_step

		var fence := FENCE_SCENE.instantiate()
		add_child(fence)
		fence.owner = owner

		fence.position = Vector3(
			cos(angle) * radius,
			0.0,
			sin(angle) * radius
		)

		fence.look_at(center, Vector3.UP)
		fence.rotate_y(-PI * 0.5)

	_generate_bushes(radius - 5)
	_generate_trees(radius - 5)


func _generate_bushes(radius: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var area = PI * radius * radius
	var bush_count : int = roundi(area * BUSH_DENSITY)

	var placed_positions: Array[Vector2] = []

	var attempts := 0
	var max_attempts : int = bush_count * 20

	while placed_positions.size() < bush_count and attempts < max_attempts:
		attempts += 1

		# Uniform point inside a circle
		var r = sqrt(rng.randf()) * radius
		var theta = rng.randf() * TAU
		var pos2 = Vector2(
			cos(theta) * r,
			sin(theta) * r
		)

		var valid := true
		for other in placed_positions:
			if pos2.distance_to(other) < BUSH_MIN_DISTANCE:
				valid = false
				break

		if !valid:
			continue

		placed_positions.append(pos2)

		var bush = BUSH_SCENE.instantiate()
		add_child(bush)
		bush.owner = owner

		bush.position = Vector3(pos2.x, 0.0, pos2.y)
		bush.rotation.y = rng.randf() * TAU


func _generate_trees(radius: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var area := PI * radius * radius
	var tree_count: int = roundi(area * TREE_DENSITY)

	var placed_positions: Array[Vector2] = []

	var attempts := 0
	var max_attempts := tree_count * 20

	while placed_positions.size() < tree_count and attempts < max_attempts:
		attempts += 1

		var r := sqrt(rng.randf()) * radius
		var theta := rng.randf() * TAU
		var pos2 := Vector2(
			cos(theta) * r,
			sin(theta) * r
		)

		var valid := true
		for other in placed_positions:
			if pos2.distance_to(other) < TREE_MIN_DISTANCE:
				valid = false
				break

		if !valid:
			continue

		placed_positions.append(pos2)

		var tree_scene: PackedScene = TREE_SCENES[rng.randi_range(0, TREE_SCENES.size() - 1)]
		var tree := tree_scene.instantiate()

		add_child(tree)
		tree.owner = owner

		tree.position = Vector3(pos2.x, 0.0, pos2.y)
		tree.rotation.y = rng.randf() * TAU
