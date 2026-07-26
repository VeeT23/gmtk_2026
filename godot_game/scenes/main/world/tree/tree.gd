extends StaticBody3D

const TREE_SCENES := [
	preload("res://assets/terrain/foliage/trees/tree_5.glb"),
	preload("res://assets/terrain/foliage/trees/tree_6.glb"),
	preload("res://assets/terrain/foliage/trees/tree_7.glb")
]

func _ready() -> void:
	var tree : Node3D = TREE_SCENES[randi_range(0, TREE_SCENES.size() - 1)].instantiate()
	add_child(tree)
	var scale_factor = randf_range(2.0,3.2)
	tree.scale = Vector3.ONE * scale_factor
	tree.rotate_y(randf() * TAU)
