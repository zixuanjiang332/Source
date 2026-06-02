class_name Hud
extends CanvasLayer

const HEALTH_FILL_WIDTH := 476.0
const ENERGY_FILL_WIDTH := 356.0

@onready var health_fill: ColorRect = $Root/Margin/HealthBack/HealthFill
@onready var health_label: Label = $Root/Margin/HealthLabel
@onready var energy_fill: ColorRect = $Root/Margin/EnergyBack/EnergyFill
@onready var energy_label: Label = $Root/Margin/EnergyLabel
@onready var weapon_icon: TextureRect = $Root/Margin/WeaponIcon
@onready var weapon_label: Label = $Root/Margin/WeaponLabel
@onready var skill_label: Label = $Root/Margin/SkillLabel
@onready var ultimate_label: Label = $Root/Margin/UltimateLabel
@onready var combo_label: Label = $Root/Margin/ComboLabel
@onready var objective_label: Label = $Root/Margin/Objective
@onready var toast_label: Label = $Root/Margin/Toast
@onready var currency_label: Label = $Root/Margin/CurrencyLabel

var _current_energy: int = 0
var _skill_cost: int = 0
var _skill_name: String = "Skill"
var _ultimate_cost: int = 100
var _ultimate_name: String = "Ultimate"
var _ultimate_hold_time: float = 0.45

func _ready() -> void:
	GameEvents.player_health_changed.connect(_on_player_health_changed)
	GameEvents.player_energy_changed.connect(_on_player_energy_changed)
	GameEvents.player_weapon_changed.connect(_on_player_weapon_changed)
	GameEvents.player_ultimate_changed.connect(_on_player_ultimate_changed)
	GameEvents.player_combo_changed.connect(_on_player_combo_changed)
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	GameEvents.item_collected.connect(_on_item_collected)
	GameEvents.objective_changed.connect(_on_objective_changed)
	GameEvents.toast_requested.connect(_show_toast)
	GameEvents.currency_changed.connect(_on_currency_changed)
	weapon_label.visible = false
	skill_label.visible = false
	ultimate_label.visible = false
	objective_label.visible = false
	toast_label.visible = false
	currency_label.text = "CR 0500"
	objective_label.text = ""
	toast_label.text = ""
	weapon_label.text = ""
	skill_label.text = ""
	ultimate_label.text = ""
	combo_label.text = ""


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP %03d/%03d" % [current_health, max_health]
	var ratio: float = 0.0
	if max_health > 0:
		ratio = clampf(float(current_health) / float(max_health), 0.0, 1.0)
	health_fill.size = Vector2(roundf(HEALTH_FILL_WIDTH * ratio), health_fill.size.y)


func _on_player_energy_changed(current_energy: int, max_energy: int) -> void:
	_current_energy = current_energy
	energy_label.text = "EN %03d/%03d" % [current_energy, max_energy]
	var ratio: float = 0.0
	if max_energy > 0:
		ratio = clampf(float(current_energy) / float(max_energy), 0.0, 1.0)
	energy_fill.size = Vector2(roundf(ENERGY_FILL_WIDTH * ratio), energy_fill.size.y)
	_update_skill_label()


func _on_player_weapon_changed(weapon_name: String, skill_name: String, skill_cost: int) -> void:
	_skill_name = skill_name
	_skill_cost = skill_cost
	weapon_label.text = "WEAPON // %s" % weapon_name
	_update_skill_label()


func _on_player_ultimate_changed(ultimate_name: String, ultimate_cost: int, hold_time: float) -> void:
	_ultimate_name = ultimate_name
	_ultimate_cost = ultimate_cost
	_ultimate_hold_time = hold_time
	_update_skill_label()


func _on_player_combo_changed(combo_step: int, combo_size: int) -> void:
	if combo_step <= 0:
		combo_label.text = ""
	else:
		combo_label.text = "CHAIN %d/%d" % [combo_step, combo_size]


func _on_enemy_defeated(enemy_id: StringName) -> void:
	_show_toast("target neutralized: %s" % String(enemy_id))


func _on_item_collected(item_id: StringName) -> void:
	_show_toast("upgrade linked: %s" % String(item_id))


func _on_objective_changed(message: String) -> void:
	objective_label.text = message


func _on_currency_changed(amount: int) -> void:
	currency_label.text = "CR %04d" % amount


func _show_toast(message: String) -> void:
	toast_label.text = message
	var tween: Tween = create_tween()
	toast_label.modulate.a = 1.0
	tween.tween_interval(1.2)
	tween.tween_property(toast_label, "modulate:a", 0.35, 0.35)


func _update_skill_label() -> void:
	var state: String = "READY" if _current_energy >= _skill_cost else "CHARGING"
	if _skill_cost <= 0:
		state = "--"
	weapon_icon.modulate = Color.WHITE if state == "READY" else Color(0.45, 0.65, 0.72, 0.72)
	skill_label.text = "K %s // %s %d EN" % [_skill_name, state, _skill_cost]
	var ultimate_state: String = "READY" if _current_energy >= _ultimate_cost else "CHARGING"
	if _ultimate_cost <= 0:
		ultimate_state = "--"
	ultimate_label.text = "HOLD K %s // %s %d EN" % [_ultimate_name, ultimate_state, _ultimate_cost]
	ultimate_label.modulate = Color(1.0, 1.0, 1.0, 0.92) if ultimate_state == "READY" else Color(1.0, 1.0, 1.0, 0.48)
