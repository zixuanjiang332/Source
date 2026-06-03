class_name SpriteSheetVfx
extends Sprite2D

var _frame_count: int = 1
var _fps: float = 12.0
var _frame_size: Vector2i = Vector2i(64, 64)
var _timer: float = 0.0
var _frame: int = 0

func configure(entry: VfxEntry, facing: int) -> void:
	texture = entry.texture
	_frame_size = entry.frame_size
	_frame_count = max(1, entry.frame_count)
	_fps = max(1.0, entry.fps)
	region_enabled = true
	region_rect = Rect2(Vector2.ZERO, Vector2(_frame_size))
	position += Vector2(entry.origin_offset.x * facing, entry.origin_offset.y)
	scale = Vector2(absf(entry.visual_scale.x) * facing, entry.visual_scale.y)
	modulate = entry.modulate
	z_index = entry.z_index


func _process(delta: float) -> void:
	_timer += delta
	var next_frame: int = floori(_timer * _fps)
	if next_frame == _frame:
		return

	_frame = next_frame
	if _frame >= _frame_count:
		queue_free()
		return

	region_rect.position = Vector2(_frame * _frame_size.x, 0)
