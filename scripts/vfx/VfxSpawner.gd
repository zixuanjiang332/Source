class_name VfxSpawner
extends Node2D

const SPRITE_SHEET_VFX_SCRIPT = preload("res://scripts/vfx/SpriteSheetVfx.gd")

const MAX_SFX_PLAYERS := 8
var _sfx_pool: Array[AudioStreamPlayer2D] = []
var _sfx_pool_index: int = 0

@export var catalog: VfxCatalog = preload("res://resources/vfx/vfx_catalog.tres")

func _ready() -> void:
	GameEvents.vfx_requested.connect(_on_vfx_requested)
	GameEvents.sfx_requested.connect(_on_sfx_requested)


func _on_vfx_requested(vfx_id: StringName, world_position: Vector2, facing: int) -> void:
	var sheet_entry: VfxEntry = catalog.sheet_entry_for(vfx_id)
	if sheet_entry != null:
		var sheet_instance: Sprite2D = Sprite2D.new()
		sheet_instance.set_script(SPRITE_SHEET_VFX_SCRIPT)
		sheet_instance.global_position = world_position
		sheet_instance.call("configure", sheet_entry, facing)
		add_child(sheet_instance)
		return

	var scene: PackedScene = catalog.scene_for(vfx_id)
	if scene == null:
		return

	var instance: Node2D = scene.instantiate() as Node2D
	instance.global_position = world_position
	instance.scale.x = absf(instance.scale.x) * facing
	add_child(instance)


func _on_sfx_requested(sfx_id: StringName, world_position: Vector2) -> void:
	var sfx_entry: SfxEntry = catalog.sfx_entry_for(sfx_id)
	if sfx_entry == null or sfx_entry.stream == null:
		return

	var player: AudioStreamPlayer2D = _acquire_sfx_player()
	player.stream = sfx_entry.stream
	player.volume_db = sfx_entry.volume_db
	player.pitch_scale = sfx_entry.pitch_scale
	player.global_position = world_position
	player.play()


func _acquire_sfx_player() -> AudioStreamPlayer2D:
	# 优先复用池中空闲的播放器
	for p in _sfx_pool:
		if p != null and is_instance_valid(p) and not p.playing:
			return p

	# 池未满则新建
	if _sfx_pool.size() < MAX_SFX_PLAYERS:
		var new_player := AudioStreamPlayer2D.new()
		new_player.finished.connect(new_player.queue_free)
		add_child(new_player)
		_sfx_pool.append(new_player)
		return new_player

	# 池满则回收最旧的
	var oldest := _sfx_pool[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % MAX_SFX_PLAYERS
	if oldest != null and is_instance_valid(oldest):
		oldest.stop()
	return oldest

func _disconnect_signals() -> void:
	if GameEvents.vfx_requested.is_connected(_on_vfx_requested):
		GameEvents.vfx_requested.disconnect(_on_vfx_requested)
	if GameEvents.sfx_requested.is_connected(_on_sfx_requested):
		GameEvents.sfx_requested.disconnect(_on_sfx_requested)


