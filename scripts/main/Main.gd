extends Node

const DEMO_LEVEL_SCENE = preload("res://scenes/levels/DemoLevel.tscn")
const HUD_SCENE = preload("res://scenes/ui/Hud.tscn")
const VFX_SPAWNER_SCRIPT = preload("res://scripts/vfx/VfxSpawner.gd")
const MINIMAL_VISUAL_MODE := true

@onready var game_root: Node = $GameRoot
@onready var title_layer: CanvasLayer = get_node_or_null("TitleLayer") as CanvasLayer
@onready var start_button: Button = get_node_or_null("TitleLayer/StartButton") as Button
@onready var combat_button: Button = get_node_or_null("TitleLayer/CombatButton") as Button
@onready var archive_button: Button = get_node_or_null("TitleLayer/ArchiveButton") as Button
@onready var chip_button: Button = get_node_or_null("TitleLayer/ChipButton") as Button
@onready var settings_button: Button = get_node_or_null("TitleLayer/SettingsButton") as Button
@onready var menu_notice: Label = get_node_or_null("TitleLayer/MenuNotice") as Label
@onready var pause_overlay: CanvasItem = get_node_or_null("PauseLayer/PauseOverlay") as CanvasItem
@onready var shop: CanvasLayer = $Shop

var _title_active := true
var _game_started := false
var _notice_tween: Tween
var _shop_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	GameEvents.run_reset_requested.connect(_reload_run)
	GameEvents.shop_requested.connect(_on_shop_requested)
	GameEvents.shop_closed.connect(_on_shop_closed)

	if start_button != null:
		start_button.pressed.connect(_start_run)
	if combat_button != null:
		combat_button.pressed.connect(_show_locked_notice.bind("战斗模式"))
	if archive_button != null:
		archive_button.pressed.connect(_show_locked_notice.bind("核心档案"))
	if chip_button != null:
		chip_button.pressed.connect(_show_locked_notice.bind("芯片系统"))
	if settings_button != null:
		settings_button.pressed.connect(_show_locked_notice.bind("系统设置"))
	if pause_overlay != null:
		pause_overlay.visible = false

	if _has_title_menu():
		_show_title()
	else:
		_title_active = false
		_game_started = true
		if title_layer != null:
			title_layer.visible = false
		_build_gameplay()


func _unhandled_input(_event: InputEvent) -> void:
	if _title_active and (
		Input.is_action_just_pressed("attack")
		or Input.is_action_just_pressed("jump")
		or Input.is_action_just_pressed("interact")
	):
		_start_run()
	elif _game_started and _shop_open and Input.is_action_just_pressed("pause"):
		return
	elif _game_started and Input.is_action_just_pressed("restart"):
		_reload_run()
	elif _game_started and Input.is_action_just_pressed("pause"):
		_toggle_pause()


func _reload_run() -> void:
	if not _game_started:
		return

	Engine.time_scale = 1.0
	get_tree().paused = false
	if pause_overlay != null:
		pause_overlay.visible = false
	_clear_gameplay()
	_build_gameplay()


func _show_title() -> void:
	_title_active = true
	_game_started = false
	if title_layer != null:
		title_layer.visible = true
	if menu_notice != null:
		menu_notice.modulate.a = 0.0
	get_tree().paused = false
	if pause_overlay != null:
		pause_overlay.visible = false
	_clear_gameplay()


func _start_run() -> void:
	if _game_started:
		return

	_title_active = false
	_game_started = true
	if title_layer != null:
		title_layer.visible = false
	if pause_overlay != null:
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
	if pause_overlay != null:
		pause_overlay.visible = get_tree().paused


func _on_shop_requested(_shop_id: StringName) -> void:
	if MINIMAL_VISUAL_MODE:
		return
	_shop_open = true
	if shop != null:
		shop.open(_shop_id)
	get_tree().paused = true


func _on_shop_closed() -> void:
	_shop_open = false
	get_tree().paused = false


func _show_locked_notice(option_name: String) -> void:
	if menu_notice == null:
		return
	menu_notice.text = "%s // Demo 暂未开放" % option_name
	menu_notice.modulate.a = 1.0
	if _notice_tween != null:
		_notice_tween.kill()
	_notice_tween = create_tween()
	_notice_tween.tween_interval(1.15)
	_notice_tween.tween_property(menu_notice, "modulate:a", 0.0, 0.25)


func _has_title_menu() -> bool:
	return (
		title_layer != null
		and start_button != null
		and combat_button != null
		and archive_button != null
		and chip_button != null
		and settings_button != null
		and menu_notice != null
	)
