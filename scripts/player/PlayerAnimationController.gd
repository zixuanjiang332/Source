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


func _play_animation(animation_id: StringName) -> bool:
	if not _has_animation(animation_id):
		_show_fallback()
		return false

	if _current_animation == animation_id and animated_sprite.is_playing():
		return true

	_current_animation = animation_id
	animated_sprite.visible = true
	_set_fallback_visible(false)
	animated_sprite.play(animation_id)
	return true


func _has_animation(animation_id: StringName) -> bool:
	return (
		animated_sprite != null
		and animated_sprite.sprite_frames != null
		and animated_sprite.sprite_frames.has_animation(animation_id)
	)


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
