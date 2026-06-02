class_name WeaponPickup
extends Area2D

@export var weapon_data: WeaponData

@onready var body: Sprite2D = $Body
@onready var label: Label = $Label

var _base_y := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_y = position.y
	if weapon_data != null:
		label.text = weapon_data.display_name
	else:
		label.text = "Unknown Weapon"


func _process(delta: float) -> void:
	position.y = _base_y + sin(Time.get_ticks_msec() * 0.006) * 3.0
	rotation += delta * 0.9


func _on_body_entered(body_node: Node2D) -> void:
	# Auto-pickup when player touches the weapon
	if body_node.has_method("apply_weapon_pickup"):
		body_node.apply_weapon_pickup(weapon_data)
		GameEvents.request_vfx(&"item_pickup", global_position, 1)
		queue_free()
