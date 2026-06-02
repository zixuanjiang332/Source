class_name RebirthLevel
extends Node2D

@onready var route_label: Label = $RouteLabel

func _ready() -> void:
	route_label.text = "Awakening route // rebirth lab"
	_configure_player_camera()
	call_deferred("_announce_start")


func _announce_start() -> void:
	GameEvents.request_objective("WAKE // speak with Dr. Lin")


func _configure_player_camera() -> void:
	var camera := get_node_or_null("Actors/Player/Camera2D") as Camera2D
	if camera == null:
		return

	camera.zoom = Vector2(2.0, 2.0)
	camera.limit_left = 0
	camera.limit_right = 960
	camera.limit_top = -180
	camera.limit_bottom = 360
