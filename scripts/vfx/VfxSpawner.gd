class_name VfxSpawner
extends Node2D

@export var catalog = preload("res://resources/vfx/vfx_catalog.tres")

func _ready() -> void:
	GameEvents.vfx_requested.connect(_on_vfx_requested)
	GameEvents.sfx_requested.connect(_on_sfx_requested)


func _on_vfx_requested(vfx_id: StringName, world_position: Vector2, facing: int) -> void:
	var scene = catalog.scene_for(vfx_id)
	if scene == null:
		return

	var instance := scene.instantiate() as Node2D
	instance.global_position = world_position
	instance.scale.x = absf(instance.scale.x) * facing
	add_child(instance)


func _on_sfx_requested(_sfx_id: StringName, _world_position: Vector2) -> void:
	# Placeholder until authored WAV/OGG assets are imported.
	pass
