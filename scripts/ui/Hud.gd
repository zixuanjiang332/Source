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
@onready var accessory_bar: AccessoryBar = $Root/AccessoryBar

var _current_energy: int = 0
var _skill_cost: int = 0
var _skill_name: String = "Skill"
var _ultimate_cost: int = 100
var _ultimate_name: String = "Ultimate"
var _ultimate_hold_time: float = 0.45

func _ready() -> void:
	GameEvents.player_health_changed.connect(_on_player_health_changed)
	GameEvents.player_energy_changed.connect(_on_player_energy_changed)


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
