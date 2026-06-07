class_name WeaponPickup
extends Area2D

@export var weapon_data: WeaponData
@export var weapon_scale: float = 0.08
@export var prompt_text: String = "E WEAPON"

@onready var body: Sprite2D = $Body
@onready var prompt_label: Label = get_node_or_null("PromptLabel") as Label
var _base_y: float = 0.0
var _nearby_players: Array[Node2D] = []

func _ready() -> void:
	_base_y = position.y
	add_to_group("weapon_pickups")
	_ensure_prompt_label()
	_sync_visuals()
	body.scale = Vector2(weapon_scale, weapon_scale)
	_set_prompt_visible(false)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func set_weapon_data(value: WeaponData) -> void:
	weapon_data = value
	_sync_visuals()


func is_player_in_range(player: Node2D) -> bool:
	return _nearby_players.has(player) or global_position.distance_to(player.global_position) <= 48.0


func try_pickup(player: Node2D) -> bool:
	if weapon_data == null:
		return false
	if not is_player_in_range(player):
		return false
	if not player.has_method("apply_weapon_pickup"):
		return false
	var picked_up := bool(player.apply_weapon_pickup(weapon_data))
	if not picked_up:
		return false
	GameEvents.request_vfx(&"item_pickup", global_position, 1)
	queue_free()
	return true


func _sync_visuals() -> void:
	if not is_node_ready():
		return
	if weapon_data != null:
		body.texture = weapon_data.resolved_world_texture()
	else:
		body.texture = null


func _process(_delta: float) -> void:
	position.y = _base_y + sin(Time.get_ticks_msec() * 0.006) * 3.0
	_refresh_prompt_visibility()


func _on_body_entered(body_node: Node2D) -> void:
	if body_node != null and body_node.is_in_group("player") and not _nearby_players.has(body_node):
		_nearby_players.append(body_node)


func _on_body_exited(body_node: Node2D) -> void:
	_nearby_players.erase(body_node)


func _ensure_prompt_label() -> void:
	if prompt_label != null:
		prompt_label.text = prompt_text
		return

	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.offset_left = -48.0
	prompt_label.offset_top = -56.0
	prompt_label.offset_right = 48.0
	prompt_label.offset_bottom = -28.0
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.text = prompt_text
	prompt_label.z_index = 10
	prompt_label.add_theme_font_size_override("font_size", 14)
	prompt_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.42, 0.96))
	add_child(prompt_label)


func _refresh_prompt_visibility() -> void:
	var visible := false
	for player in _nearby_players:
		if player != null and is_instance_valid(player) and is_player_in_range(player):
			visible = true
			break
	_set_prompt_visible(visible)


func _set_prompt_visible(is_visible: bool) -> void:
	if prompt_label != null:
		prompt_label.visible = is_visible
