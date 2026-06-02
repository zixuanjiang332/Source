class_name WeaponPickup
extends Area2D

@export var weapon_data: WeaponData

@onready var body: Sprite2D = $Body

var _base_y := 0.0
var _player_nearby: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_base_y = position.y
	if weapon_data != null:
		if weapon_data.icon_texture != null:
			body.texture = weapon_data.icon_texture


func _process(delta: float) -> void:
	position.y = _base_y + sin(Time.get_ticks_msec() * 0.006) * 3.0

	if _player_nearby != null and Input.is_action_just_pressed("interact"):
		pickup()


func _on_body_entered(body_node: Node2D) -> void:
	if body_node.is_in_group("player"):
		_player_nearby = body_node


func _on_body_exited(body_node: Node2D) -> void:
	if body_node == _player_nearby:
		_player_nearby = null


func pickup() -> void:
	if _player_nearby != null and _player_nearby.has_method("apply_weapon_pickup"):
		_player_nearby.apply_weapon_pickup(weapon_data)
		GameEvents.request_vfx(&"item_pickup", global_position, 1)
		queue_free()
