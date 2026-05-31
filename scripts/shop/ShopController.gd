class_name Shop
extends CanvasLayer

enum State { BROWSE, CONFIRM, MESSAGE }

const CYAN := Color(0.16, 0.95, 1, 0.95)
const MAGENTA := Color(1, 0.18, 0.68, 0.95)
const PANEL_BG := Color(0.02, 0.03, 0.05, 0.95)
const SLOT_BG := Color(0.015, 0.02, 0.035, 0.9)
const SLOT_SELECTED := Color(0.04, 0.08, 0.12, 0.95)
const OVERLAY_COLOR := Color(0.01, 0.012, 0.02, 0.85)

const PANEL_MARGIN := 4.0
const PANEL_W := 480.0
const PANEL_H := 270.0
const SLOT_H := 28.0
const SLOT_MARGIN := 2.0
const SLOT_W := 468.0
const VISIBLE_SLOTS := 7
const HEADER_H := 20.0
const FOOTER_H := 14.0

@export var catalog: ShopCatalog

var _state: State = State.BROWSE
var _selected_index := 0
var _scroll_offset := 0
var _current_item: ShopData = null
var _confirm_yes := true
var _slot_nodes: Array[Control] = []
var _items: Array[ShopData] = []

@onready var bg_overlay: ColorRect = $BgOverlay
@onready var panel: Control = $Panel
@onready var inner_back: ColorRect = $Panel/InnerBack
@onready var inner_frame: Line2D = $Panel/InnerFrame
@onready var panel_accent: Line2D = $Panel/PanelAccent
@onready var title_label: Label = $Panel/TitleLabel
@onready var currency_label: Label = $Panel/CurrencyLabel
@onready var items_vbox: VBoxContainer = $Panel/ItemsVBox
@onready var confirm_panel: Control = $Panel/ConfirmPanel
@onready var confirm_label: Label = $Panel/ConfirmPanel/ConfirmLabel
@onready var yes_label: Label = $Panel/ConfirmPanel/YesLabel
@onready var no_label: Label = $Panel/ConfirmPanel/NoLabel
@onready var message_label: Label = $Panel/MessageLabel
@onready var hints_label: Label = $Panel/HintsLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	GameEvents.shop_requested.connect(_on_shop_requested)
	GameEvents.currency_changed.connect(_on_currency_changed)
	confirm_panel.visible = false
	message_label.visible = false


func open(shop_id: StringName = &"main") -> void:
	if catalog == null:
		return
	_items = catalog.items.duplicate()
	if _items.is_empty():
		return
	_selected_index = 0
	_scroll_offset = 0
	_state = State.BROWSE
	visible = true
	confirm_panel.visible = false
	message_label.visible = false
	_build_slots()
	_update_currency_label()
	_update_selection()


func close() -> void:
	visible = false
	GameEvents.report_shop_closed()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	match _state:
		State.BROWSE:
			_handle_browse(event)
		State.CONFIRM:
			_handle_confirm(event)
		State.MESSAGE:
			_handle_message(event)


func _handle_browse(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_up"):
		_navigate(-1)
	elif Input.is_action_just_pressed("move_down"):
		_navigate(1)
	elif Input.is_action_just_pressed("interact"):
		_try_select()
	elif Input.is_action_just_pressed("pause"):
		close()


func _handle_confirm(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down"):
		_confirm_yes = not _confirm_yes
		_update_confirm_selection()
	elif Input.is_action_just_pressed("interact"):
		if _confirm_yes:
			_execute_purchase()
		else:
			_cancel_confirm()
	elif Input.is_action_just_pressed("pause"):
		_cancel_confirm()


func _handle_message(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		message_label.visible = false
		_state = State.BROWSE


func _navigate(direction: int) -> void:
	_selected_index = wrapi(_selected_index + direction, 0, _items.size())
	if _selected_index < _scroll_offset:
		_scroll_offset = _selected_index
	elif _selected_index >= _scroll_offset + VISIBLE_SLOTS:
		_scroll_offset = _selected_index - VISIBLE_SLOTS + 1
	_update_selection()


func _try_select() -> void:
	if _selected_index >= _items.size():
		return
	_current_item = _items[_selected_index]
	if _current_item.stock == 0:
		_show_message("SOLD OUT")
		return
	var cm := _get_currency_manager()
	if cm and not cm.can_afford(_current_item.price):
		_show_message("INSUFFICIENT CREDITS")
		return
	_state = State.CONFIRM
	_confirm_yes = true
	confirm_label.text = "PURCHASE %s?" % _current_item.item_data.display_name
	confirm_panel.visible = true
	_update_confirm_selection()


func _execute_purchase() -> void:
	if _current_item == null:
		return
	var cm := _get_currency_manager()
	if cm:
		cm.spend(_current_item.price)
	var player := _get_player()
	if player and player.has_method("apply_item"):
		player.apply_item(_current_item.item_data)
	if _current_item.stock > 0:
		_current_item.stock -= 1
	GameEvents.report_item_purchased(_current_item.shop_item_id, _current_item.item_data)
	GameEvents.request_toast("purchased: %s" % _current_item.item_data.display_name)
	_cancel_confirm()


func _cancel_confirm() -> void:
	_state = State.BROWSE
	confirm_panel.visible = false
	_update_selection()


func _show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true
	message_label.modulate.a = 1.0
	_state = State.MESSAGE
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(message_label, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func() -> void:
		message_label.visible = false
		_state = State.BROWSE
	)


func _build_slots() -> void:
	for child in items_vbox.get_children():
		child.queue_free()
	_slot_nodes.clear()
	var items_to_show := mini(_items.size(), VISIBLE_SLOTS)
	for i in items_to_show:
		var slot := Control.new()
		slot.custom_minimum_size = Vector2(SLOT_W, SLOT_H)
		_build_slot_content(slot, i)
		items_vbox.add_child(slot)
		_slot_nodes.append(slot)


func _build_slot_content(slot: Control, display_index: int) -> void:
	var back := ColorRect.new()
	back.name = "Back"
	back.position = Vector2.ZERO
	back.size = Vector2(SLOT_W, SLOT_H)
	back.color = SLOT_BG
	slot.add_child(back)

	var frame := Line2D.new()
	frame.name = "Frame"
	frame.width = 1.0
	frame.default_color = Color(CYAN.r, CYAN.g, CYAN.b, 0.3)
	frame.points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(SLOT_W, 0),
		Vector2(SLOT_W, SLOT_H),
		Vector2(0, SLOT_H),
		Vector2(0, 0),
	])
	slot.add_child(frame)

	var name_label := Label.new()
	name_label.name = "ItemName"
	name_label.position = Vector2(8, 3)
	name_label.size = Vector2(280, 10)
	name_label.add_theme_font_size_override("font_size", 7)
	name_label.text = _items[display_index].item_data.display_name
	name_label.modulate = Color(0.85, 0.92, 0.96, 1)
	slot.add_child(name_label)

	var desc_label := Label.new()
	desc_label.name = "ItemDesc"
	desc_label.position = Vector2(8, 14)
	desc_label.size = Vector2(280, 10)
	desc_label.add_theme_font_size_override("font_size", 6)
	desc_label.text = _items[display_index].item_data.description
	desc_label.modulate = Color(0.6, 0.7, 0.75, 0.9)
	slot.add_child(desc_label)

	var price_label := Label.new()
	price_label.name = "PriceLabel"
	price_label.position = Vector2(370, 6)
	price_label.size = Vector2(90, 10)
	price_label.add_theme_font_size_override("font_size", 7)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var price_text := "%03d CR" % _items[display_index].price
	if _items[display_index].stock == 0:
		price_text = "SOLD OUT"
		price_label.modulate = MAGENTA
	else:
		var cm := _get_currency_manager()
		if cm and not cm.can_afford(_items[display_index].price):
			price_label.modulate = MAGENTA
		else:
			price_label.modulate = CYAN
	price_label.text = price_text
	slot.add_child(price_label)

	var icon := Polygon2D.new()
	icon.name = "Icon"
	icon.position = Vector2(SLOT_W - 10, SLOT_H / 2.0)
	icon.polygon = PackedVector2Array([
		Vector2(-3, -5),
		Vector2(3, -5),
		Vector2(5, 0),
		Vector2(3, 5),
		Vector2(-3, 5),
		Vector2(-5, 0),
	])
	icon.color = CYAN
	icon.modulate.a = 0.7
	slot.add_child(icon)


func _update_selection() -> void:
	for i in _slot_nodes.size():
		var slot := _slot_nodes[i]
		var actual_index := _scroll_offset + i
		var is_selected := actual_index == _selected_index
		var back: ColorRect = slot.get_node("Back")
		var frame: Line2D = slot.get_node("Frame")
		back.color = SLOT_SELECTED if is_selected else SLOT_BG
		frame.default_color = CYAN if is_selected else Color(CYAN.r, CYAN.g, CYAN.b, 0.3)
		frame.width = 2.0 if is_selected else 1.0


func _update_confirm_selection() -> void:
	yes_label.modulate = CYAN if _confirm_yes else Color(0.5, 0.5, 0.55, 0.8)
	no_label.modulate = MAGENTA if not _confirm_yes else Color(0.5, 0.5, 0.55, 0.8)


func _update_currency_label() -> void:
	var cm := _get_currency_manager()
	if cm:
		currency_label.text = "CR %04d" % cm.get_balance()


func _on_shop_requested(_shop_id: StringName) -> void:
	open(_shop_id)


func _on_currency_changed(amount: int) -> void:
	currency_label.text = "CR %04d" % amount


func _get_currency_manager() -> Node:
	return get_node_or_null("/root/CurrencyManager")


func _get_player() -> Node:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0]
