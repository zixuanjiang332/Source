class_name CameraJuice
extends Camera2D

var _shake_strength := 0.0
var _shake_timer := 0.0

func _ready() -> void:
	GameEvents.camera_impulse_requested.connect(_on_camera_impulse_requested)


func _process(delta: float) -> void:
	if _shake_timer <= 0.0:
		offset = Vector2.ZERO
		return

	_shake_timer = max(0.0, _shake_timer - delta)
	var falloff := _shake_timer
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_strength * 3.5 * falloff


func _on_camera_impulse_requested(strength: float, duration: float) -> void:
	_shake_strength = max(_shake_strength, strength)
	_shake_timer = max(_shake_timer, duration)
