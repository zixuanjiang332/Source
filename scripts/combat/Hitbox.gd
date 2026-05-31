class_name Hitbox
extends Area2D

signal hit_landed(target: Node, attack_data)

var attack_data
@export var source_path: NodePath = NodePath("../..")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _source: Node2D
var _facing := 1
var _active := false
var _token := 0
var _targets_hit := {}

func _ready() -> void:
	monitoring = false
	monitorable = false
	collision_shape.disabled = true
	area_entered.connect(_on_area_entered)


func activate(next_attack, next_source: Node2D, next_facing: int) -> void:
	if next_attack == null:
		return

	_token += 1
	var token := _token
	attack_data = next_attack
	_source = next_source
	_facing = signi(next_facing)
	if _facing == 0:
		_facing = 1

	_targets_hit.clear()
	_active = true
	monitorable = true
	monitoring = true
	collision_shape.disabled = false

	await get_tree().create_timer(attack_data.active_time).timeout
	if token == _token:
		deactivate()


func deactivate() -> void:
	_token += 1
	_active = false
	monitoring = false
	monitorable = false
	if collision_shape != null:
		collision_shape.disabled = true
	_targets_hit.clear()


func _on_area_entered(area: Area2D) -> void:
	if not _active or attack_data == null:
		return

	if not area.has_method("receive_hit") or not area.has_method("get_receiver"):
		return

	var target: Node = area.call("get_receiver")
	if target == null or target == _source:
		return

	var key := area.get_instance_id()
	if _targets_hit.has(key):
		return

	_targets_hit[key] = true
	area.call("receive_hit", attack_data, _source, global_position, _facing)
	hit_landed.emit(target, attack_data)
	GameEvents.request_vfx(attack_data.vfx_id, global_position, _facing)
	GameEvents.request_sfx(attack_data.sfx_id, global_position)
	GameEvents.request_camera_impulse(attack_data.screen_shake, 0.06)


func signi(value: int) -> int:
	if value < 0:
		return -1
	if value > 0:
		return 1
	return 0
