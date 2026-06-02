class_name PlayerController
extends CharacterBody2D

const DEFAULT_STATS = preload("res://resources/characters/player_stats.tres")
const DEFAULT_WEAPON = preload("res://resources/weapons/initial_dagger.tres")
const WEAPON_PICKUP_SCENE = preload("res://scenes/items/WeaponPickup.tscn")
const MINIMAL_VISUAL_MODE := true
const ATTACK_CHAIN = [
	preload("res://resources/attacks/dagger_cut_1.tres"),
	preload("res://resources/attacks/dagger_cut_2.tres"),
	preload("res://resources/attacks/dagger_cut_3.tres"),
]
const SKILL_ATTACK = preload("res://resources/attacks/dagger_flash_step.tres")
const VISUAL_SCALE := 0.90
const ULTIMATE_STEP_INTERVAL := 0.085
const ULTIMATE_BLUE_HITBOX_SIZE := Vector2(168.0, 62.0)
const ULTIMATE_RED_HITBOX_SIZE := Vector2(188.0, 96.0)
const ULTIMATE_BLUE_OFFSETS := [
	Vector2(66.0, -54.0),
	Vector2(82.0, -42.0),
	Vector2(76.0, -68.0),
	Vector2(96.0, -34.0),
	Vector2(86.0, -58.0),
	Vector2(108.0, -40.0),
	Vector2(98.0, -72.0),
]
const ULTIMATE_BLUE_HITBOX_POSITIONS := [
	Vector2(54.0, -38.0),
	Vector2(68.0, -34.0),
	Vector2(64.0, -46.0),
	Vector2(74.0, -30.0),
	Vector2(70.0, -40.0),
	Vector2(82.0, -32.0),
	Vector2(86.0, -48.0),
]

@export var stats = DEFAULT_STATS
@export var weapon_data = DEFAULT_WEAPON

@onready var visual_root: Node2D = $VisualRoot
@onready var animated_sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite
@onready var body: Polygon2D = $VisualRoot/FallbackRoot/Body
@onready var visor: Polygon2D = $VisualRoot/FallbackRoot/Visor
@onready var hitbox = $FacingPivot/Hitbox
@onready var hitbox_collision_shape: CollisionShape2D = $FacingPivot/Hitbox/CollisionShape2D
@onready var hurtbox = $Hurtbox
@onready var facing_pivot: Node2D = $FacingPivot
@onready var debug_label: Label = $DebugLabel
@onready var animation_controller: Node = $AnimationController

var _runtime_stats
var _health := 1
var _energy := 1
var _facing := 1
var _dash_timer := 0.0
var _dash_cooldown_timer := 0.0
var _attack_locked := false
var _combo_index := 0
var _combo_reset_timer := 0.0
var _invulnerable_timer := 0.0
var _damage_multiplier := 1.0
var _dead := false
var _last_reported_combo := -1
var _skill_hold_timer := 0.0
var _skill_hold_active := false
var _skill_hold_consumed := false
var _ultimate_active := false
var _default_hitbox_position := Vector2.ZERO
var _default_hitbox_size := Vector2.ZERO
var _previous_equipped_index := -1
var _weapon_charge_timer := 0.0
var _weapon_skill_ready := false
var _last_attack_hit_targets: Array[Node] = []
var inventory: Array[WeaponData] = []
var equipped_index: int = 0

func _ready() -> void:
	if MINIMAL_VISUAL_MODE and debug_label != null:
		debug_label.visible = false
	add_to_group("player")
	_prepare_hitbox_shape()
	_runtime_stats = stats.runtime_copy()
	_health = _runtime_stats.max_health
	_energy = _runtime_stats.max_energy
	GameEvents.report_player_health(_health, _runtime_stats.max_health)
	GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
	inventory.append(weapon_data)
	equipped_index = 0
	_apply_equipped_weapon_modifiers()
	_report_weapon()
	GameEvents.report_player_combo(0, _attack_chain().size())
	hitbox.hit_landed.connect(_on_hit_landed)
	_update_facing_visual()
	_update_movement_animation()


func _physics_process(delta: float) -> void:
	if _dead:
		velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * delta)
		velocity.y += _gravity() * delta
		move_and_slide()
		return

	_tick_timers(delta)

	if _ultimate_active:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_debug_label()
		return

	if _dash_timer > 0.0:
		velocity.x = _facing * _runtime_stats.dash_speed
		velocity.y = 0.0
		move_and_slide()
		animation_controller.play_state(&"dash")
		_update_debug_label()
		return

	var axis := Input.get_axis("move_left", "move_right")
	if not is_zero_approx(axis):
		_facing = 1 if axis > 0.0 else -1
		velocity.x = move_toward(velocity.x, axis * _runtime_stats.move_speed, _runtime_stats.acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * delta)

	if not is_on_floor():
		velocity.y += _gravity() * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = _runtime_stats.jump_velocity

	if Input.is_action_just_pressed("dash") and _dash_cooldown_timer <= 0.0:
		_start_dash()

	if Input.is_action_just_pressed("attack"):
		_try_attack()

	_handle_weapon_input()

	_update_skill_input(delta)

	_update_facing_visual()
	move_and_slide()
	_update_movement_animation()
	_update_debug_label()


func apply_hit(attack_data, source: Node2D, _hit_position: Vector2, facing: int) -> void:
	if _dead or _invulnerable_timer > 0.0:
		return

	_health = max(0, _health - attack_data.damage)
	GameEvents.report_player_health(_health, _runtime_stats.max_health)
	_invulnerable_timer = max(attack_data.hit_stun, 0.12)

	var knock_direction := facing
	if source != null:
		knock_direction = 1 if global_position.x >= source.global_position.x else -1
	velocity.x = attack_data.knockback.x * knock_direction
	velocity.y = attack_data.knockback.y
	_flash(Color(1.0, 0.18, 0.22, 1.0))

	if _health <= 0:
		_die()
	else:
		animation_controller.play_action(&"hit")


func apply_item(item_data) -> void:
	match item_data.effect_id:
		&"damage_multiplier":
			_damage_multiplier += item_data.magnitude
		&"heal":
			_health = min(_runtime_stats.max_health, _health + roundi(item_data.magnitude))
		&"dash_cooldown":
			_runtime_stats.dash_cooldown = max(0.12, _runtime_stats.dash_cooldown - item_data.magnitude)
		&"max_health":
			_runtime_stats.max_health += roundi(item_data.magnitude)
			_health = min(_runtime_stats.max_health, _health + roundi(item_data.magnitude))

	GameEvents.report_player_health(_health, _runtime_stats.max_health)
	GameEvents.report_item_collected(item_data.item_id)


func apply_weapon_pickup(wd: WeaponData) -> void:
	if wd == null:
		return

	if inventory.size() >= 3:
		var replaced = inventory[equipped_index]
		inventory[equipped_index] = wd
		weapon_data = wd
		_apply_equipped_weapon_modifiers()
		_report_weapon()
		GameEvents.request_toast("Replaced %s with %s" % [replaced.display_name, wd.display_name])
	else:
		inventory.append(wd)
		equip_weapon(inventory.size() - 1)
		GameEvents.request_toast("Equipped: %s" % wd.display_name)


func pickup_weapon() -> void:
	var pickup := _nearest_weapon_pickup()
	if pickup == null:
		GameEvents.request_toast("No weapon in range")
		return
	if not pickup.try_pickup(self):
		GameEvents.request_toast("Weapon not ready")


func equip_weapon(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return
	if equipped_index == index:
		return

	if equipped_index >= 0 and equipped_index < inventory.size():
		_previous_equipped_index = equipped_index
	equipped_index = index
	weapon_data = inventory[equipped_index]
	_apply_equipped_weapon_modifiers()
	_report_weapon()
	GameEvents.request_toast("Switched to: %s" % weapon_data.display_name)


func try_equip_slot(slot: int) -> void:
	# If the slot has a weapon, equip it
	if slot < inventory.size():
		equip_weapon(slot)
	else:
		# Slot is empty - try to equip next available weapon
		var next_index := (slot + 1) % 3
		var attempts := 0
		while attempts < 3:
			if next_index < inventory.size() and next_index != equipped_index:
				equip_weapon(next_index)
				return
			next_index = (next_index + 1) % 3
			attempts += 1
		# No other weapon available
		GameEvents.request_toast("Slot %d empty" % (slot + 1))


func switch_previous_weapon() -> void:
	if _previous_equipped_index < 0 or _previous_equipped_index >= inventory.size():
		GameEvents.request_toast("No previous weapon")
		return
	if _previous_equipped_index == equipped_index:
		GameEvents.request_toast("No previous weapon")
		return
	equip_weapon(_previous_equipped_index)


func drop_weapon() -> void:
	if inventory.is_empty():
		return

	if inventory.size() <= 1:
		GameEvents.request_toast("Cannot drop last weapon!")
		return

	var dropped: WeaponData = inventory[equipped_index]

	inventory.remove_at(equipped_index)
	var replacement_index: int = mini(equipped_index, inventory.size() - 1)
	if _previous_equipped_index == equipped_index:
		_previous_equipped_index = -1
	elif _previous_equipped_index > equipped_index:
		_previous_equipped_index -= 1
	equipped_index = clampi(replacement_index, 0, inventory.size() - 1)
	weapon_data = inventory[equipped_index]
	_apply_equipped_weapon_modifiers()
	_report_weapon()
	_spawn_dropped_weapon_pickup(dropped)
	GameEvents.request_toast("Dropped: %s" % dropped.display_name)


func is_alive() -> bool:
	return not _dead


func _tick_timers(delta: float) -> void:
	_dash_timer = max(0.0, _dash_timer - delta)
	_dash_cooldown_timer = max(0.0, _dash_cooldown_timer - delta)
	_invulnerable_timer = max(0.0, _invulnerable_timer - delta)
	_combo_reset_timer = max(0.0, _combo_reset_timer - delta)
	_tick_weapon_charge(delta)
	if _combo_reset_timer <= 0.0 and _last_reported_combo != 0:
		_combo_index = 0
		_report_combo(0)


func _update_skill_input(delta: float) -> void:
	if Input.is_action_just_pressed("skill") and not _attack_locked:
		if _weapon_skill_uses_charge():
			_try_weapon_charge_skill()
			return
		_skill_hold_active = true
		_skill_hold_consumed = false
		_skill_hold_timer = 0.0

	if _skill_hold_active:
		_skill_hold_timer += delta
		if _skill_hold_timer >= _ultimate_hold_time():
			if _can_start_ultimate():
				_skill_hold_active = false
				_skill_hold_consumed = true
				_start_ultimate()
			elif not _skill_hold_consumed:
				_skill_hold_consumed = true
				GameEvents.request_toast("%s charging // %d EN" % [_ultimate_name(), _ultimate_cost()])

	if Input.is_action_just_released("skill") and _skill_hold_active:
		_skill_hold_active = false
		if not _skill_hold_consumed:
			_try_skill()


func _start_dash() -> void:
	_dash_timer = _runtime_stats.dash_duration
	_dash_cooldown_timer = _runtime_stats.dash_cooldown
	_invulnerable_timer = max(_invulnerable_timer, _runtime_stats.dash_duration)
	animation_controller.play_state(&"dash")
	GameEvents.request_vfx(&"dash_burst", global_position + Vector2(0.0, -28.0), _facing)
	GameEvents.request_camera_impulse(0.35, 0.04)


func _try_attack() -> void:
	if _attack_locked or _skill_hold_active:
		return

	var chain := _attack_chain()
	if chain.is_empty():
		return

	var combo_step := _combo_index + 1
	var template: Resource = chain[_combo_index]
	_combo_index = (_combo_index + 1) % chain.size()
	_combo_reset_timer = 0.72
	_report_combo(combo_step)
	_start_attack(template)


func _try_skill() -> void:
	var skill_attack: Resource = _skill_attack()
	if skill_attack == null:
		return

	if _attack_locked or _ultimate_active:
		return

	if _energy < skill_attack.energy_cost:
		GameEvents.request_toast("%s charging // %d EN" % [_skill_name(), skill_attack.energy_cost])
		return

	_energy -= skill_attack.energy_cost
	GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
	_combo_index = 0
	_report_combo(0)
	GameEvents.request_vfx(&"dash_burst", global_position + Vector2(0.0, -30.0), _facing)
	GameEvents.request_toast("%s // execution window" % _skill_name())
	_start_attack(skill_attack)


func _start_attack(template: Resource) -> void:
	_attack_locked = true
	_last_attack_hit_targets.clear()
	var attack = template.duplicate(true)
	attack.damage = max(1, roundi(float(attack.damage) * _damage_multiplier * _weapon_damage_scale()))
	attack.cooldown = max(0.04, attack.cooldown / _weapon_attack_speed_scale())
	velocity.x += _facing * attack.lunge
	_update_facing_visual()
	animation_controller.play_action(_resolve_attack_animation(attack))
	_restore_hitbox()
	hitbox.activate(attack, self, _facing)

	await get_tree().create_timer(attack.cooldown).timeout
	_attack_locked = false
	animation_controller.clear_action()
	_update_movement_animation()


func _start_ultimate() -> void:
	var attacks := _ultimate_attacks()
	if attacks.size() < 8:
		GameEvents.request_toast("ultimate data missing")
		return

	_energy -= _ultimate_cost()
	GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
	_combo_index = 0
	_report_combo(0)
	_ultimate_active = true
	_attack_locked = true
	velocity = Vector2.ZERO
	GameEvents.request_toast("%s // execution" % _ultimate_name())
	GameEvents.request_sfx(&"sfx_yuan_ult_charge_01", global_position)
	GameEvents.request_camera_impulse(0.55, 0.08)

	await get_tree().create_timer(0.16).timeout
	if _dead:
		_finish_ultimate()
		return

	_show_visual(false)
	for index in range(7):
		var attack: Resource = attacks[index].duplicate(true)
		_configure_hitbox(ULTIMATE_BLUE_HITBOX_POSITIONS[index], ULTIMATE_BLUE_HITBOX_SIZE)
		var offset: Vector2 = ULTIMATE_BLUE_OFFSETS[index]
		GameEvents.request_vfx(&"yuan_ult_afterimage", global_position + Vector2(_facing * -10.0, 0.0), _facing)
		GameEvents.request_vfx(attack.vfx_id, global_position + Vector2(_facing * offset.x, offset.y), _facing)
		GameEvents.request_sfx(&"sfx_yuan_ult_afterimage_01", global_position)
		GameEvents.request_camera_impulse(attack.screen_shake, 0.035)
		hitbox.activate(attack, self, _facing)
		await get_tree().create_timer(ULTIMATE_STEP_INTERVAL).timeout
		if _dead:
			_finish_ultimate()
			return

	_show_visual(true)
	animation_controller.play_action(&"ultimate_slam")
	GameEvents.request_sfx(&"sfx_yuan_ult_red_drop_01", global_position)
	GameEvents.request_vfx(&"yuan_ult_red_slam_arc", global_position + Vector2(_facing * 48.0, -58.0), _facing)
	await get_tree().create_timer(0.18).timeout
	if _dead:
		_finish_ultimate()
		return

	var red_attack: Resource = attacks[7].duplicate(true)
	_configure_hitbox(Vector2(74.0, -48.0), ULTIMATE_RED_HITBOX_SIZE)
	GameEvents.request_vfx(&"yuan_ult_red_impact", global_position + Vector2(_facing * 86.0, -38.0), _facing)
	GameEvents.request_camera_impulse(red_attack.screen_shake, 0.12)
	hitbox.activate(red_attack, self, _facing)
	await get_tree().create_timer(red_attack.cooldown).timeout
	_finish_ultimate()


func _finish_ultimate() -> void:
	hitbox.deactivate()
	_restore_hitbox()
	_show_visual(true)
	_ultimate_active = false
	_attack_locked = false
	if _dead:
		return
	animation_controller.clear_action()
	_update_movement_animation()


func _on_hit_landed(_target: Node, attack_data) -> void:
	var energy_gain: int = 0
	if attack_data.energy_regen > 0:
		energy_gain = int(attack_data.energy_regen)
	_energy = min(_runtime_stats.max_energy, _energy + energy_gain)
	GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
	if _target != null and not _last_attack_hit_targets.has(_target):
		_last_attack_hit_targets.append(_target)
	_apply_weapon_passive_on_hit(_target, attack_data)
	_apply_hit_stop(attack_data.hit_stop)


func _apply_hit_stop(duration: float) -> void:
	if duration <= 0.0:
		return

	var previous_scale := Engine.time_scale
	Engine.time_scale = min(previous_scale, 0.18)
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = previous_scale


func _update_facing_visual() -> void:
	facing_pivot.scale.x = _facing
	$VisualRoot.scale = Vector2(_facing * VISUAL_SCALE, VISUAL_SCALE)


func _update_movement_animation() -> void:
	if _dead:
		return

	if _dash_timer > 0.0:
		animation_controller.play_state(&"dash")
	elif not is_on_floor():
		if velocity.y < 0.0:
			animation_controller.play_state(&"jump")
		else:
			animation_controller.play_state(&"fall")
	elif absf(velocity.x) > 4.0:
		animation_controller.play_state(&"run")
	else:
		animation_controller.play_state(&"idle")


func _update_debug_label() -> void:
	if debug_label == null or not debug_label.visible:
		return
	var state := "AIR"
	if is_on_floor():
		state = "READY"
	if _dash_timer > 0.0:
		state = "DASH"
	if _attack_locked:
		state = "STRIKE"
	if _ultimate_active:
		state = "OVERDRIVE"
	debug_label.text = state


func _attack_chain() -> Array:
	if weapon_data != null and weapon_data.has_method("attack_chain"):
		var chain: Array = weapon_data.attack_chain()
		if not chain.is_empty():
			return chain
	return ATTACK_CHAIN


func _skill_attack() -> Resource:
	if weapon_data != null and weapon_data.get("skill_attack") != null:
		return weapon_data.skill_attack
	return SKILL_ATTACK


func _skill_name() -> String:
	if weapon_data != null and weapon_data.get("skill_display_name") != null:
		return weapon_data.skill_display_name
	return "Skill"


func _ultimate_name() -> String:
	if weapon_data != null and weapon_data.get("ultimate_display_name") != null:
		return weapon_data.ultimate_display_name
	return "Ultimate"


func _ultimate_cost() -> int:
	if weapon_data != null and weapon_data.get("ultimate_energy_cost") != null:
		return weapon_data.ultimate_energy_cost
	return _runtime_stats.max_energy


func _ultimate_hold_time() -> float:
	if weapon_data != null and weapon_data.get("ultimate_hold_time") != null:
		return weapon_data.ultimate_hold_time
	return 0.45


func _ultimate_attacks() -> Array:
	if weapon_data != null and weapon_data.has_method("ultimate_attack_chain"):
		return weapon_data.ultimate_attack_chain()
	return []


func _can_start_ultimate() -> bool:
	return (
		not _attack_locked
		and not _ultimate_active
		and _energy >= _ultimate_cost()
		and _ultimate_attacks().size() >= 8
	)


func _report_weapon() -> void:
	GameEvents.report_player_weapon(weapon_data)
	GameEvents.report_player_ultimate(_ultimate_name(), _ultimate_cost(), _ultimate_hold_time())


func _report_combo(combo_step: int) -> void:
	if _last_reported_combo == combo_step:
		return
	_last_reported_combo = combo_step
	GameEvents.report_player_combo(combo_step, _attack_chain().size())


func _prepare_hitbox_shape() -> void:
	_default_hitbox_position = hitbox.position
	var rect := hitbox_collision_shape.shape as RectangleShape2D
	if rect == null:
		return

	hitbox_collision_shape.shape = rect.duplicate()
	rect = hitbox_collision_shape.shape as RectangleShape2D
	_default_hitbox_size = rect.size


func _configure_hitbox(local_position: Vector2, size: Vector2) -> void:
	hitbox.position = local_position
	var rect := hitbox_collision_shape.shape as RectangleShape2D
	if rect != null:
		rect.size = size


func _restore_hitbox() -> void:
	hitbox.position = _default_hitbox_position
	var rect := hitbox_collision_shape.shape as RectangleShape2D
	if rect != null and _default_hitbox_size != Vector2.ZERO:
		rect.size = _default_hitbox_size


func _show_visual(is_visible: bool) -> void:
	visual_root.visible = is_visible


func _flash(color: Color) -> void:
	animated_sprite.modulate = color
	body.modulate = color
	visor.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(body, "modulate", Color.WHITE, 0.1)
	tween.parallel().tween_property(visor, "modulate", Color(0.35, 1.0, 1.0, 1.0), 0.1)


func _die() -> void:
	_dead = true
	hitbox.deactivate()
	body.modulate = Color(0.22, 0.22, 0.28, 1.0)
	animation_controller.play_action(&"death")
	if debug_label != null and debug_label.visible:
		debug_label.text = "OFFLINE - R"
	GameEvents.request_camera_impulse(1.2, 0.18)


func _resolve_attack_animation(attack) -> StringName:
	if attack != null and attack.has_method("resolved_animation_id"):
		return attack.resolved_animation_id()
	if attack != null:
		return attack.attack_id
	return &"atk_1"


func _gravity() -> float:
	return ProjectSettings.get_setting("physics/2d/default_gravity") * _runtime_stats.gravity_scale


func _handle_weapon_input() -> void:
	if Input.is_action_just_pressed("drop_weapon"):
		drop_weapon()

	if Input.is_action_just_pressed("interact"):
		pickup_weapon()

	if Input.is_action_just_pressed("weapon_slot_1"):
		try_equip_slot(0)
	if Input.is_action_just_pressed("weapon_slot_2"):
		try_equip_slot(1)
	if Input.is_action_just_pressed("weapon_slot_3"):
		try_equip_slot(2)
	if Input.is_action_just_pressed("switch_previous_weapon"):
		switch_previous_weapon()


func _apply_equipped_weapon_modifiers() -> void:
	_damage_multiplier = 1.0
	_runtime_stats.move_speed = stats.move_speed
	_runtime_stats.max_health = stats.max_health
	_weapon_charge_timer = 0.0
	_weapon_skill_ready = false
	_last_attack_hit_targets.clear()
	if weapon_data == null:
		_health = min(_health, _runtime_stats.max_health)
		GameEvents.report_player_health(_health, _runtime_stats.max_health)
		return
	_runtime_stats.move_speed = stats.move_speed * weapon_data.equip_move_speed_scale
	_runtime_stats.max_health = max(1, roundi(float(stats.max_health) * weapon_data.equip_max_health_scale))
	_health = min(_health, _runtime_stats.max_health)
	GameEvents.report_player_health(_health, _runtime_stats.max_health)


func _weapon_damage_scale() -> float:
	if weapon_data == null:
		return 1.0
	return weapon_data.attack_damage_scale


func _weapon_attack_speed_scale() -> float:
	if weapon_data == null:
		return 1.0
	return maxf(0.1, weapon_data.attack_speed_scale)


func _nearest_weapon_pickup() -> WeaponPickup:
	var nearest: WeaponPickup = null
	var nearest_distance := INF
	for node in get_tree().get_nodes_in_group("weapon_pickups"):
		var pickup := node as WeaponPickup
		if pickup == null or not is_instance_valid(pickup):
			continue
		if not pickup.is_player_in_range(self):
			continue
		var distance := global_position.distance_squared_to(pickup.global_position)
		if distance < nearest_distance:
			nearest = pickup
			nearest_distance = distance
	return nearest


func _spawn_dropped_weapon_pickup(dropped_weapon: WeaponData) -> void:
	if dropped_weapon == null:
		return
	var pickup := WEAPON_PICKUP_SCENE.instantiate() as WeaponPickup
	if pickup == null:
		return
	pickup.set_weapon_data(dropped_weapon)
	pickup.global_position = global_position + Vector2(_facing * 28.0, -8.0)
	var parent := get_parent()
	if parent == null:
		parent = get_tree().current_scene
	if parent != null:
		parent.add_child(pickup)


func _tick_weapon_charge(delta: float) -> void:
	if not _weapon_skill_uses_charge():
		return
	if _weapon_skill_ready:
		return
	_weapon_charge_timer += delta
	if _weapon_charge_timer >= weapon_data.skill_charge_time:
		_weapon_charge_timer = weapon_data.skill_charge_time
		_weapon_skill_ready = true
		GameEvents.request_toast("%s ready" % _skill_name())


func _weapon_skill_uses_charge() -> bool:
	return (
		weapon_data != null
		and weapon_data.skill_charge_time > 0.0
		and _skill_attack() != null
	)


func _try_weapon_charge_skill() -> void:
	if not _weapon_skill_ready:
		var remain := maxf(0.0, weapon_data.skill_charge_time - _weapon_charge_timer)
		GameEvents.request_toast("%s charging // %.1fs" % [_skill_name(), remain])
		return
	_weapon_skill_ready = false
	_weapon_charge_timer = 0.0
	_try_skill()


func _apply_weapon_passive_on_hit(target: Node, attack_data) -> void:
	if weapon_data == null or target == null:
		return
	match weapon_data.passive_effect_id:
		&"katana_execute":
			_apply_katana_execute_passive(target, attack_data)


func _apply_katana_execute_passive(target: Node, attack_data) -> void:
	if weapon_data == null:
		return
	if _last_attack_hit_targets.size() < weapon_data.passive_threshold:
		return
	if not target.has_method("apply_hit"):
		return
	var is_boss := target.has_method("is_boss_enemy") and target.is_boss_enemy()
	if is_boss:
		var bonus_attack = attack_data.duplicate(true)
		bonus_attack.damage = max(1, roundi(float(attack_data.damage) * weapon_data.passive_boss_damage_scale))
		target.apply_hit(bonus_attack, self, global_position, _facing)
		GameEvents.request_toast("%s // boss break" % weapon_data.display_name)
		return
	if target.has_method("health_ratio") and target.health_ratio() <= weapon_data.passive_execute_health_ratio:
		var execute_attack = attack_data.duplicate(true)
		execute_attack.damage = 999999
		target.apply_hit(execute_attack, self, global_position, _facing)
		GameEvents.request_toast("%s // execute" % weapon_data.display_name)
