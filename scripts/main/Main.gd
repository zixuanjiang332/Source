extends Node

@onready var pause_overlay: CanvasItem = $PauseLayer/PauseOverlay

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	GameEvents.run_reset_requested.connect(_reload_run)
	pause_overlay.visible = false


func _unhandled_input(_event: InputEvent) -> void:
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
