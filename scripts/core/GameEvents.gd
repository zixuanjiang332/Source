extends Node

signal player_health_changed(current_health: int, max_health: int)
signal player_energy_changed(current_energy: int, max_energy: int)
signal player_weapon_changed(weapon_name: String, skill_name: String, skill_cost: int)
signal player_combo_changed(combo_step: int, combo_size: int)
signal enemy_defeated(enemy_id: StringName)
signal camera_impulse_requested(strength: float, duration: float)
signal vfx_requested(vfx_id: StringName, world_position: Vector2, facing: int)
signal sfx_requested(sfx_id: StringName, world_position: Vector2)
signal item_collected(item_id: StringName)
signal objective_changed(message: String)
signal toast_requested(message: String)
signal run_reset_requested
signal shop_requested(shop_id: StringName)
signal shop_closed
signal currency_changed(current_amount: int)
signal item_purchased(shop_item_id: StringName, item_data: Resource)

func report_player_health(current_health: int, max_health: int) -> void:
	player_health_changed.emit(current_health, max_health)


func report_player_energy(current_energy: int, max_energy: int) -> void:
	player_energy_changed.emit(current_energy, max_energy)


func report_player_weapon(weapon_name: String, skill_name: String, skill_cost: int) -> void:
	player_weapon_changed.emit(weapon_name, skill_name, skill_cost)


func report_player_combo(combo_step: int, combo_size: int) -> void:
	player_combo_changed.emit(combo_step, combo_size)


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


func request_objective(message: String) -> void:
	objective_changed.emit(message)


func request_toast(message: String) -> void:
	toast_requested.emit(message)


func request_run_reset() -> void:
	run_reset_requested.emit()


func request_shop(shop_id: StringName = &"main") -> void:
	shop_requested.emit(shop_id)


func report_shop_closed() -> void:
	shop_closed.emit()


func report_currency_changed(current_amount: int) -> void:
	currency_changed.emit(current_amount)


func report_item_purchased(shop_item_id: StringName, item_data: Resource) -> void:
	item_purchased.emit(shop_item_id, item_data)
