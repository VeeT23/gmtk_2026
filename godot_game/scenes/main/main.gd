extends Node

## Seconds of silence between plays of the main song, picked at random.
@export var music_gap_min : float = 45.0
@export var music_gap_max : float = 120.0
## Wait this long before the first play instead of starting immediately.
@export var music_first_delay : float = 20.0

const MAIN_SONG := preload("res://assets/sfx/interaction/MAINSong.mp3")
const DINO_SCENE := preload("res://scenes/t_rex/t_rex.tscn")

var dino = null

var music_player : AudioStreamPlayer
var music_timer : float = 0.0

var immunity := 0.0

func _ready() -> void:
	GameState.begin_countdown()
	$Canvas/UI/Transition.fade_in_finished.connect(_fade_in_finished)
	$Canvas/UI/Transition.fade_out_finished.connect(_fade_out_finished)

	_setup_music_player()
	music_timer = music_first_delay

## Uses an AudioStreamPlayer from the scene if there is one, otherwise makes its own.
func _setup_music_player() -> void:
	music_player = find_child("MusicPlayer", true, false) as AudioStreamPlayer
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		music_player.bus = &"Master"
		add_child(music_player)

	if music_player.stream == null:
		music_player.stream = MAIN_SONG
	# Autoplay would start it before the timer gets a say.
	music_player.autoplay = false
	music_player.stop()

func _process(delta: float) -> void:
	_update_periodic_music(delta)
	immunity = max(immunity - delta, 0.0)

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
	if immunity > 0.0:
		return
	GameState.is_player_dead = true
	$Canvas/UI/DeathScreen.show_death_screen()
	immunity = 10.0

func respawn_player() -> void:
	print("Respawning player")
	var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
	player.respawn()
	$Canvas/UI/DeathScreen.hide_death_screen()
	$Canvas/UI/Transition.fade_in()
	GameState.is_player_dead = false


func act_trigger(key: String):
	if key == "dino_spawn":
		if GameState.game_state["collected_bolt_cutters"] and !GameState.game_state["dino_spawned"]:
			GameState.change_state("dino_spawned", true)
			call_deferred("_spawn_dino")

	if key == "walked_by_bush" and !GameState.game_state["passed_bush"]:
		GameState.change_state("passed_bush", true)
		GameState.queue_dialog("walked_by_bush")


func _spawn_dino():
	print("Moving dino")
	
	var spawn = get_tree().get_first_node_in_group("DinoSpawn")
	var target = get_tree().get_first_node_in_group("StartTarget")
	
	dino = DINO_SCENE.instantiate()
	add_child(dino)
	
	dino.global_position = spawn.global_position
	dino.clear_target()
	dino.set_target(target.global_position)
