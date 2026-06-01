class_name MainCityLevel
extends Node2D

@onready var route_label: Label = $RouteLabel

var _defeated_count := 0

func _ready() -> void:
	route_label.text = "Combat route // machine high road"
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	_configure_player_camera()
	call_deferred("_announce_start")


func _announce_start() -> void:
	GameEvents.request_objective("SURFACE // cross the robot high road")
	GameEvents.request_toast("city route loaded // keep moving")


func _configure_player_camera() -> void:
	var camera := get_node_or_null("Actors/Player/Camera2D") as Camera2D
	if camera == null:
		return

	camera.zoom = Vector2(2.0, 2.0)
	camera.limit_left = 0
	camera.limit_right = 3840
	camera.limit_top = -180
	camera.limit_bottom = 360


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
