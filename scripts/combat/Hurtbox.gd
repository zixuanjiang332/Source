class_name Hurtbox
extends Area2D

signal hit_received(attack_data, source: Node2D)

@export var receiver_path: NodePath = NodePath("..")

func _ready() -> void:
	add_to_group("hurtboxes")

func get_receiver() -> Node:
	var receiver: Node = get_node_or_null(receiver_path)
	if receiver != null:
		return receiver
	return owner


func receive_hit(attack_data, source: Node2D, hit_position: Vector2, facing: int) -> void:
	var receiver: Node = get_receiver()
	if receiver != null and receiver.has_method("apply_hit"):
		receiver.apply_hit(attack_data, source, hit_position, facing)
	hit_received.emit(attack_data, source)
