class_name DemoLevel
extends Node2D

@onready var route_label: Label = $RouteLabel

var _defeated_count := 0

func _ready() -> void:
	route_label.text = "Awakening route // lab to surface city"
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	call_deferred("_announce_start")


func _announce_start() -> void:
	GameEvents.request_objective("WAKE // speak with Dr. Lin")


func _on_enemy_defeated(_enemy_id: StringName) -> void:
	_defeated_count += 1
	match _defeated_count:
		1:
			route_label.text = "Combat route // scout cleared"
			GameEvents.request_objective("CHAIN // break the riot frame")
			GameEvents.request_toast("chain window // J-J-J")
		2:
			route_label.text = "Combat route // frame broken"
			GameEvents.request_objective("FINISH // spend K Flash Step")
			GameEvents.request_toast("energy live // K Flash Step")
		_:
			route_label.text = "Combat route // clear"
			GameEvents.request_objective("CLEAR // route recorded")
			GameEvents.request_toast("combat slice complete // press R to rerun")
