class_name PickupItem
extends Area2D

@export var item_data = preload("res://resources/items/damage_amp.tres")

@onready var body: Polygon2D = $Body
@onready var label: Label = $Label

var _base_y := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_y = position.y
	label.text = item_data.display_name


func _process(delta: float) -> void:
	position.y = _base_y + sin(Time.get_ticks_msec() * 0.006) * 3.0


func _on_body_entered(body_node: Node2D) -> void:
	if body_node.has_method("apply_item"):
		body_node.apply_item(item_data)
		GameEvents.request_vfx(&"item_pickup", global_position, 1)
		queue_free()
