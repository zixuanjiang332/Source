class_name Hud
extends CanvasLayer

const MINIMAL_VISUAL_MODE := true

@onready var weapon_icon: TextureRect = $Root/Margin/WeaponIcon
@onready var weapon_label: Label = $Root/Margin/WeaponLabel
@onready var skill_label: Label = $Root/Margin/SkillLabel
@onready var combo_label: Label = $Root/Margin/ComboLabel
@onready var objective_label: Label = $Root/Margin/Objective
@onready var toast_label: Label = $Root/Margin/Toast
@onready var currency_label: Label = $Root/Margin/CurrencyLabel

var _current_energy := 0
var _skill_cost := 0
var _skill_name := "Skill"

func _ready() -> void:
	if MINIMAL_VISUAL_MODE:
		visible = false
		return

	GameEvents.player_energy_changed.connect(_on_player_energy_changed)
	GameEvents.player_weapon_changed.connect(_on_player_weapon_changed)
	GameEvents.player_combo_changed.connect(_on_player_combo_changed)
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	GameEvents.item_collected.connect(_on_item_collected)
	GameEvents.objective_changed.connect(_on_objective_changed)
	GameEvents.toast_requested.connect(_show_toast)
	GameEvents.currency_changed.connect(_on_currency_changed)
	currency_label.text = "CR 0500"
	objective_label.text = "WAKE // speak with Dr. Lin"
	toast_label.text = "A/D move  Space jump  E interact"
	weapon_label.text = "WEAPON // initializing"
	skill_label.text = "SKILL // --"
	combo_label.text = ""


func _on_player_energy_changed(current_energy: int, max_energy: int) -> void:
	_current_energy = current_energy
	_update_skill_label()


func _on_player_weapon_changed(weapon_name: String, skill_name: String, skill_cost: int) -> void:
	_skill_name = skill_name
	_skill_cost = skill_cost
	weapon_label.text = "WEAPON // %s" % weapon_name
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
	var tween := create_tween()
	toast_label.modulate.a = 1.0
	tween.tween_interval(1.2)
	tween.tween_property(toast_label, "modulate:a", 0.35, 0.35)


func _update_skill_label() -> void:
	var state := "READY" if _current_energy >= _skill_cost else "CHARGING"
	if _skill_cost <= 0:
		state = "--"
	weapon_icon.modulate = Color.WHITE if state == "READY" else Color(0.45, 0.65, 0.72, 0.72)
	skill_label.text = "K %s // %s %d EN" % [_skill_name, state, _skill_cost]
