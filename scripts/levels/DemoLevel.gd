class_name DemoLevel
extends Node2D

const MINIMAL_VISUAL_MODE := true
const BASE_VIEWPORT_HEIGHT := 540.0
const BASE_VIEWPORT_WIDTH := 960.0
const BACKDROP_CENTER_Y := 90.0
const CAMERA_LIMIT_TOP := -180
const CAMERA_LIMIT_BOTTOM := 360
const FLOOR_Y := 234.0
const FLOOR_LINE_Y := 220.0
const PLAYER_SPAWN_X := 72.0
const PLAYER_SPAWN_Y := 220.0
const STATION_Y := 186.0
const ELEVATOR_Y := 154.0
const ELEVATOR_RIGHT_MARGIN := 122.0
const WALL_CENTER_OFFSET := 4.0

@onready var route_label: Label = get_node_or_null("RouteLabel") as Label
@onready var workshop_bg: Sprite2D = $Background/WorkshopBg
@onready var ground_shape: CollisionShape2D = $Collision/Ground/CollisionShape2D
@onready var ground_neon: Line2D = $Collision/Ground/GroundNeon
@onready var left_wall_shape: CollisionShape2D = $Collision/LeftWall/CollisionShape2D
@onready var right_wall_shape: CollisionShape2D = $Collision/RightWall/CollisionShape2D
@onready var player: CharacterBody2D = $Actors/Player
@onready var supply_station: Area2D = $Interactables/SupplyStationInteract
@onready var elevator_interact: Area2D = $Interactables/ElevatorInteract

var _defeated_count: int = 0
var _room_width: float = BASE_VIEWPORT_WIDTH

func _ready() -> void:
	if route_label != null:
		route_label.visible = not MINIMAL_VISUAL_MODE
		route_label.text = "Workshop route // supply room online"
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_responsive_layout()
	call_deferred("_announce_start")


func _announce_start() -> void:
	if MINIMAL_VISUAL_MODE:
		return
	GameEvents.request_objective("WORKSHOP // resupply, then take the city lift")
	GameEvents.request_toast("station online // shop in the center, lift on the right")


func _on_enemy_defeated(_enemy_id: StringName) -> void:
	if MINIMAL_VISUAL_MODE:
		return
	_defeated_count += 1
	match _defeated_count:
		1:
			if route_label != null:
				route_label.text = "Combat route // scout cleared"
			GameEvents.request_objective("CHAIN // break the riot frame")
			GameEvents.request_toast("chain window // J-J-J")
		2:
			if route_label != null:
				route_label.text = "Combat route // frame broken"
			GameEvents.request_objective("FINISH // spend K Flash Step")
			GameEvents.request_toast("energy live // K Flash Step")
		_:
			if route_label != null:
				route_label.text = "Combat route // clear"
			GameEvents.request_objective("CLEAR // route recorded")
			GameEvents.request_toast("combat slice complete // press R to rerun")


func _on_viewport_size_changed() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	_room_width = _resolve_room_width()
	var room_center: Vector2 = Vector2(_room_width * 0.5, BACKDROP_CENTER_Y)

	_layout_background(room_center)
	_layout_collision()
	_layout_interactables(room_center.x)
	_layout_player()
	_layout_camera()


func _resolve_room_width() -> float:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.y <= 0.0:
		return BASE_VIEWPORT_WIDTH
	return maxf(BASE_VIEWPORT_WIDTH, roundf(BASE_VIEWPORT_HEIGHT * (viewport_size.x / viewport_size.y)))


func _layout_background(room_center: Vector2) -> void:
	if workshop_bg == null or workshop_bg.texture == null:
		return

	var texture_size: Vector2 = workshop_bg.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	workshop_bg.position = room_center
	var scale_x: float = _room_width / texture_size.x
	var scale_y: float = BASE_VIEWPORT_HEIGHT / texture_size.y
	var cover_scale: float = maxf(scale_x, scale_y)
	workshop_bg.scale = Vector2.ONE * cover_scale


func _layout_collision() -> void:
	if ground_shape != null:
		var ground_rect: RectangleShape2D = ground_shape.shape as RectangleShape2D
		if ground_rect != null:
			ground_rect.size.x = _room_width
		ground_shape.position = Vector2(_room_width * 0.5, FLOOR_Y)

	if ground_neon != null:
		ground_neon.points = PackedVector2Array([
			Vector2(-12.0, FLOOR_LINE_Y),
			Vector2(_room_width + 12.0, FLOOR_LINE_Y),
		])

	if left_wall_shape != null:
		left_wall_shape.position.x = -WALL_CENTER_OFFSET

	if right_wall_shape != null:
		right_wall_shape.position.x = _room_width + WALL_CENTER_OFFSET


func _layout_interactables(center_x: float) -> void:
	if supply_station != null:
		supply_station.position = Vector2(center_x, STATION_Y)
	if elevator_interact != null:
		elevator_interact.position = Vector2(_room_width - ELEVATOR_RIGHT_MARGIN, ELEVATOR_Y)


func _layout_player() -> void:
	if player == null:
		return

	if is_zero_approx(player.position.x) or player.position == Vector2.ZERO:
		player.position = Vector2(PLAYER_SPAWN_X, PLAYER_SPAWN_Y)


func _layout_camera() -> void:
	if player == null:
		return

	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return

	camera.zoom = Vector2(2.0, 2.0)
	camera.limit_left = 0
	camera.limit_top = CAMERA_LIMIT_TOP
	camera.limit_right = int(roundf(_room_width))
	camera.limit_bottom = CAMERA_LIMIT_BOTTOM
