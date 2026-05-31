class_name VfxSpawner
extends Node2D

const SPRITE_SHEET_VFX_SCRIPT = preload("res://scripts/vfx/SpriteSheetVfx.gd")

@export var catalog = preload("res://resources/vfx/vfx_catalog.tres")

func _ready() -> void:
	GameEvents.vfx_requested.connect(_on_vfx_requested)
	GameEvents.sfx_requested.connect(_on_sfx_requested)


func _on_vfx_requested(vfx_id: StringName, world_position: Vector2, facing: int) -> void:
	var sheet_entry: VfxEntry = catalog.sheet_entry_for(vfx_id)
	if sheet_entry != null:
		var sheet_instance := Sprite2D.new()
		sheet_instance.set_script(SPRITE_SHEET_VFX_SCRIPT)
		sheet_instance.global_position = world_position
		sheet_instance.call("configure", sheet_entry, facing)
		add_child(sheet_instance)
		return

	var scene = catalog.scene_for(vfx_id)
	if scene == null:
		return

	var instance := scene.instantiate() as Node2D
	instance.global_position = world_position
	instance.scale.x = absf(instance.scale.x) * facing
	add_child(instance)


func _on_sfx_requested(sfx_id: StringName, world_position: Vector2) -> void:
	var sfx_entry: SfxEntry = catalog.sfx_entry_for(sfx_id)
	if sfx_entry == null or sfx_entry.stream == null:
		return

	var player := AudioStreamPlayer2D.new()
	player.stream = sfx_entry.stream
	player.volume_db = sfx_entry.volume_db
	player.pitch_scale = sfx_entry.pitch_scale
	player.global_position = world_position
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
