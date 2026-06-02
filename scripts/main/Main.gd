extends Node

const REBIRTH_LEVEL_SCENE = preload("res://scenes/levels/RebirthLevel.tscn")
const WORKSHOP_LEVEL_SCENE = preload("res://scenes/levels/DemoLevel.tscn")
const MAIN_CITY_LEVEL_SCENE = preload("res://scenes/levels/MainCityLevel.tscn")
const HUD_SCENE = preload("res://scenes/ui/Hud.tscn")
const VFX_SPAWNER_SCRIPT = preload("res://scripts/vfx/VfxSpawner.gd")

@onready var game_root: Node = $GameRoot
@onready var title_layer: CanvasLayer = $TitleLayer
@onready var menu_root: Control = $TitleLayer/MenuRoot
@onready var start_button: Button = $TitleLayer/MenuRoot/StartButton
@onready var combat_button: Button = $TitleLayer/MenuRoot/CombatButton
@onready var archive_button: Button = $TitleLayer/MenuRoot/ArchiveButton
@onready var chip_button: Button = $TitleLayer/MenuRoot/ChipButton
@onready var settings_button: Button = $TitleLayer/MenuRoot/SettingsButton
@onready var hover_marker: Label = $TitleLayer/MenuRoot/HoverMarker
@onready var menu_notice: Label = $TitleLayer/MenuNotice
@onready var pause_overlay: CanvasItem = $PauseLayer/PauseOverlay
@onready var transition_overlay: ColorRect = $TransitionLayer/TransitionOverlay
@onready var shop: Node = get_node_or_null("Shop")

var _title_active: bool = true
var _game_started: bool = false
var _notice_tween: Tween
var _current_level: Node = null
var _transitioning: bool = false
var _shop_open: bool = false
var _selected_button_index: int = 0
var _menu_buttons: Array[Button] = []
var _button_tweens: Dictionary = {}
var _persistent_player: CharacterBody2D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	GameEvents.run_reset_requested.connect(_reload_run)
	GameEvents.level_change_requested.connect(_on_level_change_requested)
	GameEvents.shop_requested.connect(_on_shop_requested)
	GameEvents.shop_closed.connect(_on_shop_closed)
	_menu_buttons = [start_button, combat_button, archive_button, chip_button, settings_button]
	for button: Button in _menu_buttons:
		_setup_menu_button(button)
	start_button.pressed.connect(_start_run)
	combat_button.pressed.connect(_show_locked_notice.bind("战斗模式"))
	archive_button.pressed.connect(_show_locked_notice.bind("核心档案"))
	chip_button.pressed.connect(_show_locked_notice.bind("芯片系统"))
	settings_button.pressed.connect(_show_locked_notice.bind("系统设置"))
	_show_title()
	pause_overlay.visible = false
	transition_overlay.visible = false


func _unhandled_input(_event: InputEvent) -> void:
	if _title_active and Input.is_action_just_pressed("move_down"):
		_set_selected_button(_selected_button_index + 1)
	elif _title_active and Input.is_action_just_pressed("move_up"):
		_set_selected_button(_selected_button_index - 1)
	if _title_active and (
		Input.is_action_just_pressed("attack")
		or Input.is_action_just_pressed("jump")
		or Input.is_action_just_pressed("interact")
	):
		_menu_buttons[_selected_button_index].emit_signal("pressed")
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
	pause_overlay.visible = false
	_clear_gameplay()
	_build_gameplay(false)


func _show_title() -> void:
	_title_active = true
	_game_started = false
	title_layer.visible = true
	menu_notice.modulate.a = 0.0
	get_tree().paused = false
	pause_overlay.visible = false
	transition_overlay.visible = false
	_clear_gameplay()
	_set_selected_button(0, false)


func _start_run() -> void:
	if _game_started:
		return

	_title_active = false
	_game_started = true
	title_layer.visible = false
	pause_overlay.visible = false
	transition_overlay.visible = false
	get_tree().paused = false
	_build_gameplay(true)


func _build_gameplay(reset_respawn := true) -> void:
	_persistent_player = null
	if reset_respawn:
		GameEvents.clear_respawn_point()
	var vfx_spawner: Node2D = Node2D.new()
	vfx_spawner.name = "VfxSpawner"
	vfx_spawner.set_script(VFX_SPAWNER_SCRIPT)
	game_root.add_child(vfx_spawner)

	var hud: Node = HUD_SCENE.instantiate()
	hud.name = "Hud"
	game_root.add_child(hud)

	_load_level(&"rebirth")


func _clear_gameplay() -> void:
	_close_shop()
	_persistent_player = null
	_current_level = null
	_transitioning = false
	for child in game_root.get_children():
		game_root.remove_child(child)
		child.queue_free()


func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_overlay.visible = get_tree().paused


func _on_shop_requested(shop_id: StringName) -> void:
	if shop == null or not _game_started or not shop.has_method("open"):
		return

	_shop_open = true
	shop.call("open", shop_id)
	get_tree().paused = true


func _on_shop_closed() -> void:
	_shop_open = false
	get_tree().paused = false


func _show_locked_notice(option_name: String) -> void:
	menu_notice.text = "%s // Demo 暂未开放" % option_name
	menu_notice.modulate.a = 1.0
	if _notice_tween != null:
		_notice_tween.kill()
	_notice_tween = create_tween()
	_notice_tween.tween_interval(1.15)
	_notice_tween.tween_property(menu_notice, "modulate:a", 0.0, 0.25)


func _setup_menu_button(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 48)
	button.add_theme_color_override("font_color", Color(0.34, 0.86, 1.0, 0.86))
	button.add_theme_color_override("font_hover_color", Color(0.7, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_focus_color", Color(0.7, 1.0, 1.0, 1.0))
	button.mouse_entered.connect(_on_menu_button_hovered.bind(button))
	button.mouse_exited.connect(_on_menu_button_exited.bind(button))
	button.focus_entered.connect(_on_menu_button_hovered.bind(button))


func _set_selected_button(index: int, animate := true) -> void:
	if _menu_buttons.is_empty():
		return

	_selected_button_index = posmod(index, _menu_buttons.size())
	for i in range(_menu_buttons.size()):
		if i == _selected_button_index:
			_apply_button_hover(_menu_buttons[i], animate)
		else:
			_apply_button_idle(_menu_buttons[i], animate)


func _on_menu_button_hovered(button: Button) -> void:
	var index: int = _menu_buttons.find(button)
	if index >= 0:
		_selected_button_index = index
	_set_selected_button(_selected_button_index)


func _on_menu_button_exited(button: Button) -> void:
	_apply_button_idle(button)
	if button == _menu_buttons[_selected_button_index]:
		hover_marker.visible = false


func _apply_button_hover(button: Button, animate := true) -> void:
	_tween_button_scale(button, Vector2(1.1, 1.1), animate)
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	hover_marker.visible = true
	hover_marker.position = button.position + Vector2(-58.0, 8.0)


func _apply_button_idle(button: Button, animate := true) -> void:
	_tween_button_scale(button, Vector2.ONE, animate)
	button.modulate = Color(0.78, 0.9, 1.0, 0.88)


func _tween_button_scale(button: Button, target_scale: Vector2, animate := true) -> void:
	if _button_tweens.has(button) and _button_tweens[button] != null:
		_button_tweens[button].kill()
	if not animate:
		button.scale = target_scale
		return

	var tween: Tween = create_tween()
	_button_tweens[button] = tween
	tween.tween_property(button, "scale", target_scale, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _load_level(level_id: StringName) -> void:
	_clear_current_level()
	match level_id:
		&"workshop":
			_current_level = WORKSHOP_LEVEL_SCENE.instantiate()
			_current_level.name = "WorkshopLevel"
		&"outside":
			_current_level = MAIN_CITY_LEVEL_SCENE.instantiate()
			_current_level.name = "MainCityLevel"
		&"main_city":
			_current_level = MAIN_CITY_LEVEL_SCENE.instantiate()
			_current_level.name = "MainCityLevel"
		_:
			_current_level = REBIRTH_LEVEL_SCENE.instantiate()
			_current_level.name = "RebirthLevel"
	_attach_persistent_player(_current_level)
	game_root.add_child(_current_level)
	_capture_initial_respawn_point()


func _clear_current_level() -> void:
	if _current_level == null:
		return

	game_root.remove_child(_current_level)
	_current_level.queue_free()
	_current_level = null


func _on_level_change_requested(level_id: StringName) -> void:
	if not _game_started or _transitioning:
		return

	await _transition_to_level(level_id)


func _transition_to_level(level_id: StringName) -> void:
	_transitioning = true
	transition_overlay.visible = true
	transition_overlay.modulate.a = 0.0
	var fade_in: Tween = create_tween()
	fade_in.tween_property(transition_overlay, "modulate:a", 0.94, 0.28)
	await fade_in.finished
	_capture_player_for_transition()
	_load_level(level_id)
	await get_tree().process_frame
	var fade_out: Tween = create_tween()
	fade_out.tween_interval(0.1)
	fade_out.tween_property(transition_overlay, "modulate:a", 0.0, 0.24)
	await fade_out.finished
	transition_overlay.visible = false
	_transitioning = false


func _close_shop() -> void:
	if shop != null and shop.has_method("close") and bool(shop.get("visible")):
		shop.call("close")


func _capture_player_for_transition() -> void:
	_persistent_player = null
	if _current_level == null:
		return

	var player: CharacterBody2D = _current_level.get_node_or_null("Actors/Player") as CharacterBody2D
	if player == null:
		return

	var parent: Node = player.get_parent()
	if parent != null:
		parent.remove_child(player)
	player.velocity = Vector2.ZERO
	_persistent_player = player


func _attach_persistent_player(level_root: Node) -> void:
	if level_root == null or _persistent_player == null:
		return

	var actors: Node = level_root.get_node_or_null("Actors")
	if actors == null:
		return

	var placeholder_player: Node2D = level_root.get_node_or_null("Actors/Player") as Node2D
	var target_position: Vector2 = Vector2.ZERO
	if placeholder_player != null:
		target_position = placeholder_player.position
		actors.remove_child(placeholder_player)
		placeholder_player.queue_free()

	actors.add_child(_persistent_player)
	_persistent_player.name = "Player"
	_persistent_player.position = target_position
	_persistent_player.velocity = Vector2.ZERO


func _capture_initial_respawn_point() -> void:
	if _current_level == null:
		return

	var player: Node2D = _current_level.get_node_or_null("Actors/Player") as Node2D
	if player == null:
		return

	if not GameEvents.has_respawn_point():
		GameEvents.set_respawn_point(player.global_position)
	_apply_saved_respawn_point(player)


func _apply_saved_respawn_point(player: Node2D) -> void:
	if player == null or not GameEvents.has_respawn_point():
		return

	player.global_position = GameEvents.respawn_point()
	var character: CharacterBody2D = player as CharacterBody2D
	if character != null:
		character.velocity = Vector2.ZERO
