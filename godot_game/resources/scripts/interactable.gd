class_name Interactable
extends Area3D

@export var outlined_meshes: Array[MeshInstance3D]
## Disables the collider after interaction
@export var one_shot : bool
@export_group("Tooltip")
@export var tooltip : String
@export var action : String

@export_group("SFX")

## [AudioStream] for when interacted with
@export var interact_sfx : AudioStream 

## Waits for [member interact_sfx] to finish before firing [signal interacted]
@export var fire_signal_after_sfx : bool

signal hover_entered
signal hover_exited
signal interacted

## Emitted when sfx finished, or when no sfx is assigned, emitted upon interaction
signal sfx_finished

var audio_player : AudioStreamPlayer = null

func _ready() -> void:
	if outlined_meshes.is_empty():
		push_warning("[Interactable:%s] No outlined meshes assigned." % name)
		
	for i in outlined_meshes.size():
		var mesh = outlined_meshes[i]
		
		if mesh == null:
			push_error("[Interactable:%s] outlined_meshes[%d] is null." % [name, i])

func _set_shaders(toggle : bool) -> void:
	for mesh in outlined_meshes:
		
		if mesh == null:
			continue
		if mesh.material_overlay == null:
			push_error("[Interactable:%s] Mesh '%s' has no material overlay." % [name, mesh.name])
			continue
		
		mesh.set_instance_shader_parameter("enabled", toggle)

func hover_enter() -> void:
	hover_entered.emit()
	_set_shaders(true)

func hover_exit() -> void:
	hover_exited.emit()
	_set_shaders(false)

func interact() -> void:
	if !interacted.has_connections():
		push_error("[Interactable:%s] interacted has no listeners." % name)
	if !fire_signal_after_sfx:
		_emit_interacted()
	_play_sfx()

func set_sfx(new_sfx : AudioStream) -> void:
	if audio_player:
		audio_player.stream = new_sfx
	interact_sfx = new_sfx


func _emit_interacted():
	interacted.emit()
	if !interact_sfx:
		sfx_finished.emit()
	if one_shot:
		disable()

func _play_sfx():
	if !interact_sfx:
		return
	if audio_player:
		audio_player.play()
	else:
		audio_player = AudioStreamPlayer.new()
		audio_player.stream = interact_sfx
		add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(_on_sfx_finished)

func _on_sfx_finished():
	audio_player.queue_free()
	audio_player = null
	sfx_finished.emit()
	if fire_signal_after_sfx:
		_emit_interacted()

func disable() -> void:
	for child in get_children():
			if child is CollisionShape3D:
				child.disabled = true

func enable() -> void:
	for child in get_children():
			if child is CollisionShape3D:
				child.disabled = false
