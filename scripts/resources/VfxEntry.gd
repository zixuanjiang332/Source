class_name VfxEntry
extends Resource

@export var vfx_id: StringName = &"vfx"
@export var texture: Texture2D
@export var frame_size := Vector2i(64, 64)
@export var frame_count := 1
@export var fps := 12.0
@export var origin_offset := Vector2.ZERO
@export var visual_scale := Vector2.ONE
@export var modulate := Color.WHITE
@export var z_index := 20
