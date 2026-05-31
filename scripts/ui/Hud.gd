class_name Hud
extends CanvasLayer

const HEALTH_FILL_WIDTH := 118.0

@onready var health_fill: ColorRect = $Root/Margin/HealthBack/HealthFill
@onready var health_label: Label = $Root/Margin/HealthLabel
@onready var objective_label: Label = $Root/Margin/Objective
@onready var toast_label: Label = $Root/Margin/Toast
@onready var currency_label: Label = $Root/Margin/CurrencyLabel

func _ready() -> void:
	GameEvents.player_health_changed.connect(_on_player_health_changed)
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	GameEvents.item_collected.connect(_on_item_collected)
	GameEvents.objective_changed.connect(_on_objective_changed)
	GameEvents.toast_requested.connect(_show_toast)
	GameEvents.currency_changed.connect(_on_currency_changed)
	currency_label.text = "CR 0500"
	objective_label.text = "WAKE // speak with Dr. Lin"
	toast_label.text = "A/D move  Space jump  E interact"


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP %03d/%03d" % [current_health, max_health]
	var ratio := 0.0
	if max_health > 0:
		ratio = clampf(float(current_health) / float(max_health), 0.0, 1.0)
	health_fill.size = Vector2(roundf(HEALTH_FILL_WIDTH * ratio), health_fill.size.y)


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
