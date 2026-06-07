class_name Hud
extends CanvasLayer

const HEALTH_FILL_WIDTH := 476.0
const ENERGY_FILL_WIDTH := 356.0
const WEAPON_SLOT_EMPTY_COLOR := Color(0.12, 0.15, 0.21, 0.86)
const WEAPON_SLOT_FILLED_COLOR := Color(0.09, 0.12, 0.18, 0.94)
const WEAPON_SLOT_ACTIVE_COLOR := Color(0.12, 0.22, 0.3, 0.98)
const WEAPON_SLOT_ACTIVE_BORDER := Color(1.0, 0.9, 0.42, 0.98)
const WEAPON_SLOT_IDLE_BORDER := Color(0.34, 0.94, 1.0, 0.72)

@onready var health_fill: ColorRect = $Root/Margin/HealthBack/HealthFill
@onready var health_label: Label = $Root/Margin/HealthLabel
@onready var energy_fill: ColorRect = $Root/Margin/EnergyBack/EnergyFill
@onready var energy_label: Label = $Root/Margin/EnergyLabel
@onready var ammo_label: Label = $Root/Margin/AmmoLabel
@onready var weapon_slots: Array[Control] = [
	$Root/Margin/WeaponBar/Slot1,
	$Root/Margin/WeaponBar/Slot2,
	$Root/Margin/WeaponBar/Slot3,
]

func _ready() -> void:
	GameEvents.player_health_changed.connect(_on_player_health_changed)
	GameEvents.player_energy_changed.connect(_on_player_energy_changed)
	GameEvents.player_ammo_changed.connect(_on_player_ammo_changed)
	GameEvents.player_weapon_slots_changed.connect(_on_player_weapon_slots_changed)
	_on_player_weapon_slots_changed(null, null, null, 0)


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP %03d/%03d" % [current_health, max_health]
	var ratio: float = 0.0
	if max_health > 0:
		ratio = clampf(float(current_health) / float(max_health), 0.0, 1.0)
	health_fill.size = Vector2(roundf(HEALTH_FILL_WIDTH * ratio), health_fill.size.y)


func _on_player_energy_changed(current_energy: int, max_energy: int) -> void:
	energy_label.text = "EN %03d/%03d" % [current_energy, max_energy]
	var ratio: float = 0.0
	if max_energy > 0:
		ratio = clampf(float(current_energy) / float(max_energy), 0.0, 1.0)
	energy_fill.size = Vector2(roundf(ENERGY_FILL_WIDTH * ratio), energy_fill.size.y)


func _on_player_ammo_changed(current_ammo: int, max_ammo: int, magazine_ammo: int, magazine_size: int, is_reloading: bool) -> void:
	if is_reloading:
		ammo_label.text = "AMMO RELOADING"
		return
	if max_ammo <= 0 and magazine_size <= 0:
		ammo_label.text = "AMMO ∞"
		return
	if magazine_size > 0:
		if max_ammo <= 0:
			ammo_label.text = "AMMO %02d/%02d | ∞" % [magazine_ammo, magazine_size]
		else:
			ammo_label.text = "AMMO %02d/%02d | %03d" % [magazine_ammo, magazine_size, current_ammo]
		return
	ammo_label.text = "AMMO %03d/%03d" % [current_ammo, max_ammo]


func _on_player_weapon_slots_changed(slot_0: WeaponData, slot_1: WeaponData, slot_2: WeaponData, equipped_index: int) -> void:
	var slot_data: Array[WeaponData] = [slot_0, slot_1, slot_2]
	for index in range(weapon_slots.size()):
		_update_weapon_slot(weapon_slots[index], slot_data[index], index == equipped_index, index)


func _update_weapon_slot(slot_root: Control, slot_weapon: WeaponData, is_active: bool, slot_index: int) -> void:
	if slot_root == null:
		return
	var back := slot_root.get_node("Back") as ColorRect
	var border := slot_root.get_node("Border") as Line2D
	var number_label := slot_root.get_node("SlotNumber") as Label
	var icon_rect := slot_root.get_node("WeaponIcon") as TextureRect

	if number_label != null:
		number_label.text = str(slot_index + 1)

	if slot_weapon == null:
		if back != null:
			back.color = WEAPON_SLOT_ACTIVE_COLOR if is_active else WEAPON_SLOT_EMPTY_COLOR
		if border != null:
			border.default_color = WEAPON_SLOT_ACTIVE_BORDER if is_active else WEAPON_SLOT_IDLE_BORDER
		if icon_rect != null:
			icon_rect.texture = null
			icon_rect.modulate = Color(1.0, 1.0, 1.0, 0.0)
		return

	if back != null:
		back.color = WEAPON_SLOT_ACTIVE_COLOR if is_active else WEAPON_SLOT_FILLED_COLOR
	if border != null:
		border.default_color = WEAPON_SLOT_ACTIVE_BORDER if is_active else WEAPON_SLOT_IDLE_BORDER
	if icon_rect != null:
		icon_rect.texture = slot_weapon.resolved_hud_icon()
		icon_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
