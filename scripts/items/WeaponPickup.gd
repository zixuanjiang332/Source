class_name WeaponPickup
extends Area2D

@export var weapon_data: WeaponData
@export var weapon_scale: float = 0.08

@onready var body: Sprite2D = $Body
var _base_y: float = 0.0
var _nearby_players: Array[Node2D] = []

func _ready() -> void:
	_base_y = position.y
	add_to_group("weapon_pickups")
	_sync_visuals()
	body.scale = Vector2(weapon_scale, weapon_scale)


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
	player.apply_weapon_pickup(weapon_data)
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


func _on_body_entered(body_node: Node2D) -> void:
	if body_node != null and body_node.is_in_group("player") and not _nearby_players.has(body_node):
		_nearby_players.append(body_node)


func _on_body_exited(body_node: Node2D) -> void:
	_nearby_players.erase(body_node)
