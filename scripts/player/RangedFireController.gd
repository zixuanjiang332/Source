class_name RangedFireController
extends Node

@export var player_path: NodePath = NodePath("..")

@onready var _player: PlayerController = get_node_or_null(player_path) as PlayerController

func _physics_process(_delta: float) -> void:
	if _player == null:
		return
	_player.sync_ranged_fire_input()

