class_name VfxEntry
extends Resource

@export var vfx_id: StringName = &"vfx"
@export var texture: Texture2D
@export var frame_size: Vector2i = Vector2i(64, 64)
@export var frame_count: int = 1
@export var fps: float = 12.0
@export var origin_offset: Vector2 = Vector2.ZERO
@export var visual_scale: Vector2 = Vector2.ONE
@export var modulate: Color = Color.WHITE
@export var z_index: int = 20
