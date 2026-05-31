extends Node

const DEMO_LEVEL_SCENE = preload("res://scenes/levels/DemoLevel.tscn")
const HUD_SCENE = preload("res://scenes/ui/Hud.tscn")
const VFX_SPAWNER_SCRIPT = preload("res://scripts/vfx/VfxSpawner.gd")

@onready var game_root: Node = $GameRoot
@onready var title_layer: CanvasLayer = $TitleLayer
@onready var start_button: Button = $TitleLayer/StartButton
@onready var combat_button: Button = $TitleLayer/CombatButton
@onready var archive_button: Button = $TitleLayer/ArchiveButton
@onready var chip_button: Button = $TitleLayer/ChipButton
@onready var settings_button: Button = $TitleLayer/SettingsButton
@onready var menu_notice: Label = $TitleLayer/MenuNotice
@onready var pause_overlay: CanvasItem = $PauseLayer/PauseOverlay

var _title_active := true
var _game_started := false
var _notice_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	GameEvents.run_reset_requested.connect(_reload_run)
	start_button.pressed.connect(_start_run)
	combat_button.pressed.connect(_show_locked_notice.bind("战斗模式"))
	archive_button.pressed.connect(_show_locked_notice.bind("核心档案"))
	chip_button.pressed.connect(_show_locked_notice.bind("芯片系统"))
	settings_button.pressed.connect(_show_locked_notice.bind("系统设置"))
	_show_title()
	pause_overlay.visible = false


func _unhandled_input(_event: InputEvent) -> void:
	if _title_active and (
		Input.is_action_just_pressed("attack")
		or Input.is_action_just_pressed("jump")
		or Input.is_action_just_pressed("interact")
	):
		_start_run()
	elif _game_started and Input.is_action_just_pressed("restart"):
		_reload_run()
	elif _game_started and Input.is_action_just_pressed("pause"):
		_toggle_pause()


func _reload_run() -> void:
	if not _game_started:
		return

	Engine.time_scale = 1.0
	get_tree().paused = false
	pause_overlay.visible = false
	_clear_gameplay()
	_build_gameplay()


func _show_title() -> void:
	_title_active = true
	_game_started = false
	title_layer.visible = true
	menu_notice.modulate.a = 0.0
	get_tree().paused = false
	pause_overlay.visible = false
	_clear_gameplay()


func _start_run() -> void:
	if _game_started:
		return

	_title_active = false
	_game_started = true
	title_layer.visible = false
	pause_overlay.visible = false
	get_tree().paused = false
	_build_gameplay()


func _build_gameplay() -> void:
	var vfx_spawner := Node2D.new()
	vfx_spawner.name = "VfxSpawner"
	vfx_spawner.set_script(VFX_SPAWNER_SCRIPT)
	game_root.add_child(vfx_spawner)

	var hud := HUD_SCENE.instantiate()
	hud.name = "Hud"
	game_root.add_child(hud)

	var demo_level := DEMO_LEVEL_SCENE.instantiate()
	demo_level.name = "DemoLevel"
	game_root.add_child(demo_level)


func _clear_gameplay() -> void:
	for child in game_root.get_children():
		game_root.remove_child(child)
		child.queue_free()


func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_overlay.visible = get_tree().paused


func _show_locked_notice(option_name: String) -> void:
	menu_notice.text = "%s // Demo 暂未开放" % option_name
	menu_notice.modulate.a = 1.0
	if _notice_tween != null:
		_notice_tween.kill()
	_notice_tween = create_tween()
	_notice_tween.tween_interval(1.15)
	_notice_tween.tween_property(menu_notice, "modulate:a", 0.0, 0.25)
