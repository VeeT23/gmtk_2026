extends CharacterBody3D

@export var player_path: NodePath
@export var speed: float = 5.0
@export var rotation_speed: float = 10.0

var player: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$dino/AnimationPlayer.play("MAIP_setup_BakeSystem|Skin_MAIP_setup_Root_M_bake_MAIP_setup_BakeSystem")
	
	player = get_tree().current_scene.find_child("Player", true, false) as Node3D
	
	if player == null:
		push_error("Dinosaur Error: Could not find a node named 'Player' in the scene!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if player:
		var current_pos = global_transform.origin
		var target_pos = player.global_transform.origin
		
		var direction = (target_pos - current_pos)
		direction.y = 0
		direction = direction.normalized()
		
		if direction.length_squared() > 0.001:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = rotate_toward(rotation.y, target_rotation, rotation_speed * delta)
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()
