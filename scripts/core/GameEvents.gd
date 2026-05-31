extends Node

signal player_health_changed(current_health: int, max_health: int)
signal player_energy_changed(current_energy: int, max_energy: int)
signal enemy_defeated(enemy_id: StringName)
signal camera_impulse_requested(strength: float, duration: float)
signal vfx_requested(vfx_id: StringName, world_position: Vector2, facing: int)
signal sfx_requested(sfx_id: StringName, world_position: Vector2)
signal item_collected(item_id: StringName)
signal run_reset_requested

func report_player_health(current_health: int, max_health: int) -> void:
	player_health_changed.emit(current_health, max_health)


func report_player_energy(current_energy: int, max_energy: int) -> void:
	player_energy_changed.emit(current_energy, max_energy)


func report_enemy_defeated(enemy_id: StringName) -> void:
	enemy_defeated.emit(enemy_id)


func request_camera_impulse(strength: float, duration: float) -> void:
	camera_impulse_requested.emit(strength, duration)


func request_vfx(vfx_id: StringName, world_position: Vector2, facing: int = 1) -> void:
	vfx_requested.emit(vfx_id, world_position, facing)


func request_sfx(sfx_id: StringName, world_position: Vector2) -> void:
	sfx_requested.emit(sfx_id, world_position)


func report_item_collected(item_id: StringName) -> void:
	item_collected.emit(item_id)


func request_run_reset() -> void:
	run_reset_requested.emit()

