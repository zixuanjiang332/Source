class_name AccessoryBar
extends HBoxContainer

## 雨中冒险风格的饰品栏 —— 屏幕正上方中央横向排列
## 每个饰品显示几何图标 + 堆叠数量，新加入时有弹出动画

const ICON_SIZE := 36.0
const ICON_SPACING := 8.0
const STACK_FONT_SIZE := 16
const CYAN := Color(0.16, 0.95, 1, 0.95)
const MAGENTA := Color(1, 0.18, 0.68, 0.95)
const SLOT_BG := Color(0.012, 0.018, 0.03, 0.88)
const SLOT_BORDER := Color(0.35, 1, 1, 0.86)

## 饰品 effect_id → 几何图标形状映射（赛博朋克风多边形）
var _icon_shapes: Dictionary = {}
## 饰品 effect_id → 主色调
var _icon_colors: Dictionary = {}

var _slot_map: Dictionary = {}  # item_id → { node, count }
var _slot_order: Array[StringName] = []  # 保持插入顺序


func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", ICON_SPACING)
	_init_icon_data()
	GameEvents.accessory_inventory_changed.connect(_on_accessory_inventory_changed)
	_request_initial_state()


func _init_icon_data() -> void:
	# 心脏起搏连杆 —— 心形轮廓
	_icon_shapes[&"revive_accessory"] = PackedVector2Array([
		Vector2(0, -14), Vector2(10, -6), Vector2(10, 2),
		Vector2(4, 8), Vector2(4, 14), Vector2(-4, 14),
		Vector2(-4, 8), Vector2(-10, 2), Vector2(-10, -6),
	])
	# 伤害增幅 —— 闪电形
	_icon_shapes[&"damage_multiplier"] = PackedVector2Array([
		Vector2(-2, -14), Vector2(6, -14), Vector2(2, -2),
		Vector2(10, -2), Vector2(2, 4), Vector2(6, 14),
		Vector2(-2, 8), Vector2(-6, 14), Vector2(-2, 4),
		Vector2(-10, -2), Vector2(-2, -2),
	])
	# 修复细胞 —— 十字形
	_icon_shapes[&"heal"] = PackedVector2Array([
		Vector2(-4, -14), Vector2(4, -14), Vector2(4, -4),
		Vector2(14, -4), Vector2(14, 4), Vector2(4, 4),
		Vector2(4, 14), Vector2(-4, 14), Vector2(-4, 4),
		Vector2(-14, 4), Vector2(-14, -4), Vector2(-4, -4),
	])
	# 冲刺核心 —— 箭头形
	_icon_shapes[&"dash_cooldown"] = PackedVector2Array([
		Vector2(0, -14), Vector2(12, 0), Vector2(4, 0),
		Vector2(4, 14), Vector2(-4, 14), Vector2(-4, 0),
		Vector2(-12, 0),
	])
	# 最大生命 —— 盾形
	_icon_shapes[&"max_health"] = PackedVector2Array([
		Vector2(-12, -8), Vector2(0, -14), Vector2(12, -8),
		Vector2(12, 4), Vector2(0, 14), Vector2(-12, 4),
	])

	_icon_colors[&"revive_accessory"] = Color(1, 0.18, 0.68, 0.95)
	_icon_colors[&"damage_multiplier"] = Color(1, 0.55, 0.12, 0.95)
	_icon_colors[&"heal"] = Color(0.12, 0.95, 0.45, 0.95)
	_icon_colors[&"dash_cooldown"] = Color(0.16, 0.95, 1, 0.95)
	_icon_colors[&"max_health"] = Color(0.95, 0.92, 0.12, 0.95)


func _request_initial_state() -> void:
	await get_tree().process_frame
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player = players[0]
	if player and player.get("accessory_inventory") != null:
		_on_accessory_inventory_changed(player.accessory_inventory)


func _on_accessory_inventory_changed(accessory_list: Array) -> void:
	var count_map: Dictionary = {}
	var order: Array[StringName] = []

	for item in accessory_list:
		if item == null:
			continue
		var id: StringName = item.item_id
		if id in count_map:
			count_map[id].count += 1
		else:
			count_map[id] = { data = item, count = 1 }
			order.append(id)

	# 移除不再存在的饰品
	var ids_to_remove: Array[StringName] = []
	for id in _slot_map:
		if id not in count_map:
			ids_to_remove.append(id)
	for id in ids_to_remove:
		_remove_slot(id)

	# 更新或添加饰品
	for id in order:
		var entry = count_map[id]
		if id in _slot_map:
			_update_slot_count(id, entry.count)
		else:
			_add_slot(id, entry.data, entry.count)

	_slot_order = order
	_reorder_slots()


func _add_slot(item_id: StringName, item_data: ItemData, count: int) -> void:
	var slot: Control = Control.new()
	slot.name = String(item_id)
	slot.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	slot.size = Vector2(ICON_SIZE, ICON_SIZE)

	# 背景六边形
	var bg: Polygon2D = Polygon2D.new()
	bg.name = "Bg"
	bg.polygon = _hex_shape(ICON_SIZE * 0.5)
	bg.color = SLOT_BG
	slot.add_child(bg)

	# 边框
	var border: Line2D = Line2D.new()
	border.name = "Border"
	border.width = 2.0
	border.default_color = SLOT_BORDER
	border.points = _hex_outline(ICON_SIZE * 0.5)
	slot.add_child(border)

	# 饰品图标
	var icon: Polygon2D = Polygon2D.new()
	icon.name = "Icon"
	icon.position = Vector2(ICON_SIZE * 0.5, ICON_SIZE * 0.5)
	var shape: PackedVector2Array = _icon_shapes.get(item_data.effect_id, _default_shape())
	icon.polygon = shape
	icon.color = _icon_colors.get(item_data.effect_id, CYAN)
	slot.add_child(icon)

	# 堆叠数量标签
	var stack_label: Label = Label.new()
	stack_label.name = "StackLabel"
	stack_label.position = Vector2(ICON_SIZE * 0.5, ICON_SIZE - 4)
	stack_label.size = Vector2(ICON_SIZE * 0.5, 16)
	stack_label.add_theme_font_size_override("font_size", STACK_FONT_SIZE)
	stack_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	stack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stack_label.text = "x%d" % count if count > 1 else ""
	stack_label.visible = count > 1
	slot.add_child(stack_label)

	# 弹出动画
	slot.scale = Vector2(0.0, 0.0)
	add_child(slot)
	var tween: Tween = create_tween()
	tween.tween_property(slot, "scale", Vector2(1.3, 1.3), 0.12).set_ease(Tween.EASE_OUT)
	tween.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.08).set_ease(Tween.EASE_IN)

	_slot_map[item_id] = { node = slot, count = count }


func _remove_slot(item_id: StringName) -> void:
	if item_id not in _slot_map:
		return
	var entry = _slot_map[item_id]
	var slot: Control = entry.node
	var tween: Tween = create_tween()
	tween.tween_property(slot, "scale", Vector2(0.0, 0.0), 0.15).set_ease(Tween.EASE_IN)
	tween.tween_callback(slot.queue_free)
	_slot_map.erase(item_id)


func _update_slot_count(item_id: StringName, count: int) -> void:
	if item_id not in _slot_map:
		return
	var entry = _slot_map[item_id]
	entry.count = count
	var slot: Control = entry.node
	var stack_label: Label = slot.get_node_or_null("StackLabel")
	if stack_label:
		stack_label.text = "x%d" % count if count > 1 else ""
		stack_label.visible = count > 1
	# 数量变化时闪烁动画
	var icon: Polygon2D = slot.get_node_or_null("Icon")
	if icon:
		var orig_color: Color = icon.color
		icon.modulate = Color.WHITE
		var tween: Tween = create_tween()
		tween.tween_property(icon, "modulate", orig_color, 0.2)


func _reorder_slots() -> void:
	for i in _slot_order.size():
		var id: StringName = _slot_order[i]
		if id in _slot_map:
			var slot: Control = _slot_map[id].node
			var current_index: int = slot.get_index()
			if current_index != i:
				move_child(slot, i)


func _hex_shape(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 6:
		var angle: float = PI / 3.0 * i - PI / 6.0
		points.append(Vector2(radius + cos(angle) * radius, radius + sin(angle) * radius))
	return points


func _hex_outline(radius: float) -> PackedVector2Array:
	var points := _hex_shape(radius)
	points.append(points[0])
	return points


func _default_shape() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, -12), Vector2(10, 0), Vector2(0, 12), Vector2(-10, 0),
	])
