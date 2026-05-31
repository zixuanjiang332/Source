extends Node

@onready var title_layer: CanvasLayer = $TitleLayer
@onready var start_button: Button = $TitleLayer/StartButton
@onready var restart_button: Button = $TitleLayer/RestartButton
@onready var exit_button: Button = $TitleLayer/ExitButton
@onready var pause_overlay: CanvasItem = $PauseLayer/PauseOverlay

var _title_active := true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	GameEvents.run_reset_requested.connect(_reload_run)
	start_button.pressed.connect(_start_run)
	restart_button.pressed.connect(_reload_run)
	exit_button.pressed.connect(_quit_game)
	_show_title()
	pause_overlay.visible = false


func _unhandled_input(_event: InputEvent) -> void:
	if _title_active and (
		Input.is_action_just_pressed("attack")
		or Input.is_action_just_pressed("jump")
		or Input.is_action_just_pressed("interact")
	):
		_start_run()
	elif Input.is_action_just_pressed("restart"):
		_reload_run()
	elif Input.is_action_just_pressed("pause") and not _title_active:
		_toggle_pause()


func _reload_run() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().reload_current_scene()


func _show_title() -> void:
	_title_active = true
	title_layer.visible = true
	get_tree().paused = true
	start_button.grab_focus()


func _start_run() -> void:
	_title_active = false
	title_layer.visible = false
	get_tree().paused = false


func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_overlay.visible = get_tree().paused


func _quit_game() -> void:
	get_tree().quit()
