extends Node

@export_range(0.0, 1.0) var grass_spawn_chance: float = 0.5
@export var min_grass_amount: int = 1
@export var max_grass_amount: int = 1
@export var random_rotation: bool = true
@export_range(0.5, 2.0) var min_scale: float = 0.8
@export_range(0.5, 2.0) var max_scale: float = 1.2

var grass_1 = preload("res://assets/terrain/foliage/grass/fern_1.glb")
var grass_2 = preload("res://assets/terrain/foliage/grass/fern_3.glb")
var grass_3 = preload("res://assets/terrain/foliage/grass/grass_2.glb")

var grass = [grass_1, grass_2, grass_3]


func _ready() -> void:
	spawn_grass()


func spawn_grass() -> void:
	randomize()
	for child in get_children():
		if randf() > grass_spawn_chance:
			continue
		
		var amount = randi_range(min_grass_amount, max_grass_amount)
		
		for i in amount:
			var grass_scene = grass.pick_random()
			var grass_instance = grass_scene.instantiate()
			
			add_child(grass_instance)
			
			grass_instance.global_position = child.global_position
			
			if random_rotation:
				grass_instance.rotation.y = randf_range(0.0, TAU)
			
			var scale_amount = randf_range(min_scale, max_scale)
			grass_instance.scale = Vector3.ONE * scale_amount
