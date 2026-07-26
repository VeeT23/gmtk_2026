extends Node

@onready var dino = $World/TRex

func _ready() -> void:
	GameState.begin_countdown()
	$Canvas/UI/Transition.fade_in_finished.connect(_fade_in_finished)
	$Canvas/UI/Transition.fade_out_finished.connect(_fade_out_finished)

func _fade_out_finished():
	if GameState.game_state["sent_distress_signal"]:
		await get_tree().create_timer(2.0,false, false, false).timeout
		get_tree().change_scene_to_file("res://scenes/ui/menus/win_screen/win_screen.tscn")

func _fade_in_finished():
	if !GameState.game_state["game_started"]:
		GameState.change_state("game_started", true)
		GameState.queue_dialog("game_start")

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
	$Canvas/UI/Transition.fade_in()


func act_trigger(key : String):
	if key == "dino_spawn":
		print("Moving dino")
		var spawn = get_tree().get_first_node_in_group("DinoSpawn")
		var target = get_tree().get_first_node_in_group("StartTarget")
		dino.teleport_to(spawn.global_position)
		dino.clear_target()
		dino.set_target(target.global_position)
