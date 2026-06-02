class_name PlayerAnimationController
extends Node

const DEFAULT_STATE: StringName = &"idle"
const DEATH_STATE: StringName = &"death"
@export var animated_sprite_path: NodePath = NodePath("../VisualRoot/AnimatedSprite")
@export var fallback_root_path: NodePath = NodePath("../VisualRoot/FallbackRoot")

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path)
@onready var fallback_root: CanvasItem = get_node_or_null(fallback_root_path)

var _current_animation: StringName = &""
var _action_locked := false

func _ready() -> void:
	if animated_sprite != null:
		animated_sprite.visible = false
		animated_sprite.animation_finished.connect(_on_animation_finished)

	_set_fallback_visible(true)


func play_state(state_id: StringName) -> void:
	if _action_locked:
		return

	if not _play_animation(state_id):
		_play_animation(DEFAULT_STATE)


func play_action(action_id: StringName) -> void:
	_action_locked = true
	if not _play_animation(action_id):
		if action_id == DEATH_STATE:
			_current_animation = DEATH_STATE
		_action_locked = action_id == DEATH_STATE


func clear_action() -> void:
	if _current_animation == DEATH_STATE:
		return

	_action_locked = false


func resolved_animation_id(animation_id: StringName) -> StringName:
	if _has_animation(animation_id):
		return animation_id
	return _resolved_fallback_animation_id(animation_id)


func animation_duration_for(animation_id: StringName) -> float:
	var resolved := resolved_animation_id(animation_id)
	if not _has_animation(resolved):
		return 0.0

	var frame_count := animated_sprite.sprite_frames.get_frame_count(resolved)
	var speed := animated_sprite.sprite_frames.get_animation_speed(resolved)
	if frame_count <= 0 or speed <= 0.0:
		return 0.0
	return float(frame_count) / speed


func _play_animation(animation_id: StringName) -> bool:
	var resolved_animation := animation_id
	if not _has_animation(resolved_animation):
		resolved_animation = _resolved_fallback_animation_id(animation_id)
	if not _has_animation(resolved_animation):
		_show_fallback()
		return false

	if _current_animation == resolved_animation and animated_sprite.is_playing():
		return true

	_current_animation = resolved_animation
	animated_sprite.visible = true
	_set_fallback_visible(false)
	animated_sprite.play(resolved_animation)
	return true


func _has_animation(animation_id: StringName) -> bool:
	return (
		animated_sprite != null
		and animated_sprite.sprite_frames != null
		and animated_sprite.sprite_frames.has_animation(animation_id)
	)


func _resolved_fallback_animation_id(animation_id: StringName) -> StringName:
	match animation_id:
		&"punch_1":
			return &"atk_1"
		&"punch_2":
			return &"atk_2"
		&"punch_3":
			return &"atk_3"
		&"punch_skill":
			return &"skill"
		&"combat_idle":
			return &"idle"
		&"combat_run":
			return &"run"
		&"combat_jump":
			return &"jump"
		&"combat_fall":
			return &"fall"
		&"combat_dash":
			return &"dash"
		_:
			return animation_id


func _show_fallback() -> void:
	if animated_sprite != null:
		animated_sprite.visible = false
	_set_fallback_visible(true)


func _set_fallback_visible(next_visible: bool) -> void:
	if fallback_root != null:
		fallback_root.visible = next_visible


func _on_animation_finished() -> void:
	if _current_animation == DEATH_STATE:
		var last_frame := animated_sprite.sprite_frames.get_frame_count(DEATH_STATE) - 1
		animated_sprite.frame = max(0, last_frame)
		animated_sprite.stop()
		return

	_action_locked = false
