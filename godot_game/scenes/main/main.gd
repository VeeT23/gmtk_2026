extends Node

func _ready() -> void:
	GameState.begin_countdown()
	GameState.queue_dialog("game_start")
	kill_player()

func kill_player() -> void:
	GameState.is_player_dead = true
	$Canvas/UI/DeathScreen.show_death_screen()

func respawn_player() -> void:
	print("Respawning player")
	var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
	var respawn_point : Node3D = get_tree().get_first_node_in_group("Respawn")
	player.global_position = respawn_point.global_position
	player.global_rotation = respawn_point.global_rotation
	GameState.is_player_dead = false
	$Canvas/UI/DeathScreen.hide_death_screen()
	#TODO: Move dino back in place
