class_name Hud
extends CanvasLayer

@onready var health_label: Label = $Root/Margin/Stats/Health
@onready var energy_label: Label = $Root/Margin/Stats/Energy
@onready var objective_label: Label = $Root/Margin/Objective
@onready var toast_label: Label = $Root/Margin/Toast

func _ready() -> void:
	GameEvents.player_health_changed.connect(_on_player_health_changed)
	GameEvents.player_energy_changed.connect(_on_player_energy_changed)
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	GameEvents.item_collected.connect(_on_item_collected)
	objective_label.text = "NEON MACHINE // demo route"
	toast_label.text = "J attack  K skill  Shift dash  R restart"


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP %03d/%03d" % [current_health, max_health]


func _on_player_energy_changed(current_energy: int, max_energy: int) -> void:
	energy_label.text = "EN %03d/%03d" % [current_energy, max_energy]


func _on_enemy_defeated(enemy_id: StringName) -> void:
	_show_toast("target neutralized: %s" % String(enemy_id))


func _on_item_collected(item_id: StringName) -> void:
	_show_toast("upgrade linked: %s" % String(item_id))


func _show_toast(message: String) -> void:
	toast_label.text = message
	var tween := create_tween()
	toast_label.modulate.a = 1.0
	tween.tween_interval(1.2)
	tween.tween_property(toast_label, "modulate:a", 0.35, 0.35)
