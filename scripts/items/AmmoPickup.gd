class_name AmmoPickup
extends Area2D

@export var ammo_amount: int = 12
@export var pickup_label: String = "AMMO"

@onready var label: Label = $Label

var _base_y: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_y = position.y
	if label != null:
		label.text = pickup_label


func _process(_delta: float) -> void:
	position.y = _base_y + sin(Time.get_ticks_msec() * 0.006) * 3.0


func _on_body_entered(body_node: Node2D) -> void:
	if body_node == null or not body_node.has_method("apply_ammo_pickup"):
		return
	var applied := bool(body_node.apply_ammo_pickup(ammo_amount))
	if not applied:
		return
	GameEvents.request_vfx(&"item_pickup", global_position, 1)
	queue_free()

