extends Node

@onready var pause_overlay: CanvasItem = $PauseLayer/PauseOverlay
@onready var shop: CanvasLayer = $Shop

var _shop_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	GameEvents.run_reset_requested.connect(_reload_run)
	GameEvents.shop_requested.connect(_on_shop_requested)
	GameEvents.shop_closed.connect(_on_shop_closed)
	pause_overlay.visible = false


func _unhandled_input(_event: InputEvent) -> void:
	if _shop_open:
		return
	if Input.is_action_just_pressed("restart"):
		_reload_run()
	elif Input.is_action_just_pressed("pause"):
		_toggle_pause()


func _reload_run() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().reload_current_scene()


func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_overlay.visible = get_tree().paused


func _on_shop_requested(_shop_id: StringName) -> void:
	_shop_open = true
	shop.open(_shop_id)
	get_tree().paused = true


func _on_shop_closed() -> void:
	_shop_open = false
	get_tree().paused = false
