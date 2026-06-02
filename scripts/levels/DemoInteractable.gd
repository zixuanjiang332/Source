class_name DemoInteractable
extends Area2D

@export var prompt_text := "E"
@export var speaker := ""
@export var dialogue_lines: PackedStringArray = PackedStringArray()
@export var objective_after := ""
@export var one_shot := false
@export var completed_text := "already synchronized"
@export var teleport_enabled := false
@export var teleport_target := Vector2.ZERO
@export var level_change_id: StringName = &""
@export var opens_shop := false
@export var shop_id: StringName = &"main"

@onready var prompt_label: Label = get_node_or_null("PromptLabel") as Label

var _player: Node2D = null
var _line_index := 0
var _used := false

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.text = prompt_text
	_set_prompt_visible(false)
	set_process(false)


func _process(_delta: float) -> void:
	if _player == null:
		_player = _resolve_player()
		if _player != null and not (one_shot and _used):
			_set_prompt_visible(true)

	if _player == null:
		return

	if Input.is_action_just_pressed("interact"):
		_interact()


func _on_body_entered(body: Node2D) -> void:
	if not _is_player(body):
		return

	_player = body
	set_process(true)
	if not (one_shot and _used):
		_set_prompt_visible(true)


func _on_body_exited(body: Node2D) -> void:
	if body != _player:
		return

	_player = _resolve_player()
	if _player == null:
		set_process(false)
		_set_prompt_visible(false)


func _interact() -> void:
	if _player == null:
		_player = _resolve_player()

	if one_shot and _used:
		return

	if _player == null:
		return

	if opens_shop:
		GameEvents.request_shop(shop_id)
		if one_shot:
			_used = true
			_set_prompt_visible(false)
		return

	if not dialogue_lines.is_empty():
		_line_index += 1

	if not objective_after.is_empty():
		GameEvents.request_objective(objective_after)

	if teleport_enabled and _player != null:
		var character := _player as CharacterBody2D
		if character != null:
			character.velocity = Vector2.ZERO
		_player.global_position = teleport_target
		GameEvents.request_camera_impulse(0.28, 0.08)

	if level_change_id != &"":
		GameEvents.request_level_change(level_change_id)
		return

	if one_shot:
		_used = true
		_set_prompt_visible(false)


func _is_player(body: Node2D) -> bool:
	return body.is_in_group("player") or body.has_method("apply_item")


func _set_prompt_visible(is_visible: bool) -> void:
	if prompt_label != null:
		prompt_label.visible = is_visible


func _resolve_player() -> Node2D:
	for body in get_overlapping_bodies():
		var node := body as Node2D
		if node != null and _is_player(node):
			return node
	return null
