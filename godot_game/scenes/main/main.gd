extends Node

## Seconds of silence between plays of the main song, picked at random.
@export var music_gap_min : float = 45.0
@export var music_gap_max : float = 120.0
## Wait this long before the first play instead of starting immediately.
@export var music_first_delay : float = 20.0

@onready var dino = $World/TRex
@onready var music_player : AudioStreamPlayer = $World/AudioStreamPlayer

var music_timer : float = 0.0

func _ready() -> void:
	GameState.begin_countdown()
	$Canvas/UI/Transition.fade_in_finished.connect(_fade_in_finished)
	$Canvas/UI/Transition.fade_out_finished.connect(_fade_out_finished)

	# The node has autoplay on, so silence it and let the timer drive it instead.
	music_player.stop()
	music_timer = music_first_delay

func _process(delta: float) -> void:
	_update_periodic_music(delta)

## Plays the main song every so often rather than on a constant loop.
func _update_periodic_music(delta: float) -> void:
	if music_player.playing:
		return

	music_timer -= delta
	if music_timer <= 0.0:
		music_player.play()
		music_timer = randf_range(music_gap_min, music_gap_max)

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
