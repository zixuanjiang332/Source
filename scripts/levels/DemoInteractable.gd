class_name DemoInteractable
extends Area2D

@export var prompt_text: String = "E"
@export var speaker: String = ""
@export var dialogue_lines: PackedStringArray = PackedStringArray()
@export var objective_after: String = ""
@export var one_shot: bool = false
@export var completed_text: String = "already synchronized"
@export var teleport_enabled: bool = false
@export var teleport_target: Vector2 = Vector2.ZERO
@export var level_change_id: StringName = &""
@export var opens_shop: bool = false
@export var shop_id: StringName = &"main"

@onready var prompt_label: Label = get_node_or_null("PromptLabel") as Label
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D

var _player: Node2D = null
var _player_ref: Node2D = null
var _line_index: int = 0
var _used: bool = false

func _ready() -> void:
	monitoring = true
	add_to_group("demo_interactables")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.text = prompt_text
	_set_prompt_visible(false)
	set_process(true)
	_resolve_player_ref()
	_refresh_player_presence()


func _process(_delta: float) -> void:
	_refresh_player_presence()
	if _player == null:
		return
	if _should_defer_to_weapon_pickup(_player):
		return

	if Input.is_action_just_pressed("interact"):
		_interact()


func _on_body_entered(body: Node2D) -> void:
	if not _is_player(body):
		return

	_refresh_player_presence()


func _on_body_exited(body: Node2D) -> void:
	if body != _player:
		return

	_refresh_player_presence()


func _interact() -> void:
	if _player == null:
		_refresh_player_presence()

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
		var character: CharacterBody2D = _player as CharacterBody2D
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


func can_interact(player: Node2D) -> bool:
	if player == null or (one_shot and _used):
		return false
	return _contains_player(player) or _player == player


func try_interact(player: Node2D) -> bool:
	if not can_interact(player):
		return false
	if _should_defer_to_weapon_pickup(player):
		return false
	_player = player
	_interact()
	return true


func _is_player(body: Node2D) -> bool:
	return body.is_in_group("player") or body.has_method("apply_item")


func _set_prompt_visible(is_visible: bool) -> void:
	if prompt_label != null:
		prompt_label.visible = is_visible


func _resolve_player() -> Node2D:
	if _player_ref == null or not is_instance_valid(_player_ref):
		_resolve_player_ref()
	if _player_ref != null and _contains_player(_player_ref):
		return _player_ref
	return null


func _refresh_player_presence() -> void:
	_player = _resolve_player()
	var should_show := _player != null and not (one_shot and _used)
	if should_show and _should_defer_to_weapon_pickup(_player):
		should_show = false
	_set_prompt_visible(should_show)


func _resolve_player_ref() -> void:
	_player_ref = null
	for node in get_tree().get_nodes_in_group("player"):
		var player := node as Node2D
		if player != null:
			_player_ref = player
			return


func _contains_player(player: Node2D) -> bool:
	if player == null:
		return false
	if overlaps_body(player):
		return true
	if collision_shape == null or collision_shape.shape == null:
		return false

	var local_point := collision_shape.to_local(player.global_position)
	if collision_shape.shape is RectangleShape2D:
		var rect := collision_shape.shape as RectangleShape2D
		var half := rect.size * 0.5
		return absf(local_point.x) <= half.x and absf(local_point.y) <= half.y
	if collision_shape.shape is CircleShape2D:
		var circle := collision_shape.shape as CircleShape2D
		return local_point.length_squared() <= circle.radius * circle.radius
	return false


func _should_defer_to_weapon_pickup(player: Node2D) -> bool:
	if player == null or not player.has_method("has_weapon_pickup_priority"):
		return false
	return bool(player.has_weapon_pickup_priority())
