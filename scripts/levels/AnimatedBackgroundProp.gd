class_name AnimatedBackgroundProp
extends Sprite2D

@export var frame_size: Vector2i = Vector2i.ZERO
@export var frame_count: int = 1
@export var fps: float = 8.0
@export var columns: int = 1
@export var random_start: bool = true
@export var scroll_velocity: Vector2 = Vector2.ZERO
@export var wrap_min_x: float = 0.0
@export var wrap_max_x: float = 0.0

var _current_frame: int = 0
var _frame_timer: float = 0.0

func _ready() -> void:
	frame_count = maxi(frame_count, 1)
	columns = maxi(columns, 1)
	if random_start and frame_count > 1:
		_current_frame = randi() % frame_count
	_apply_frame()


func _process(delta: float) -> void:
	_tick_animation(delta)
	_tick_scroll(delta)


func _tick_animation(delta: float) -> void:
	if fps <= 0.0 or frame_count <= 1:
		return

	_frame_timer += delta
	var frame_duration: float = 1.0 / fps
	while _frame_timer >= frame_duration:
		_frame_timer -= frame_duration
		_current_frame = (_current_frame + 1) % frame_count
		_apply_frame()


func _tick_scroll(delta: float) -> void:
	if scroll_velocity == Vector2.ZERO:
		return

	position += scroll_velocity * delta
	if wrap_max_x <= wrap_min_x:
		return

	if scroll_velocity.x > 0.0 and position.x > wrap_max_x:
		position.x = wrap_min_x
	elif scroll_velocity.x < 0.0 and position.x < wrap_min_x:
		position.x = wrap_max_x


func _apply_frame() -> void:
	if frame_size.x <= 0 or frame_size.y <= 0:
		region_enabled = false
		return

	region_enabled = true
	var column: int = _current_frame % columns
	var row: int = int(_current_frame / columns)
	region_rect = Rect2(
		Vector2(column * frame_size.x, row * frame_size.y),
		Vector2(frame_size)
	)
