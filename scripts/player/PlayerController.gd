class_name PlayerController
extends CharacterBody2D

const DEFAULT_STATS = preload("res://resources/characters/player_stats.tres")
const DEFAULT_WEAPON = preload("res://resources/weapons/initial_fists.tres")
const WEAPON_PICKUP_SCENE = preload("res://scenes/items/WeaponPickup.tscn")
const PROJECTILE_SCENE = preload("res://scenes/combat/Projectile.tscn")
const RANGED_HIT_MASK := 4
const MINIMAL_VISUAL_MODE := true
const ATTACK_CHAIN = [
	preload("res://resources/attacks/fist_jab_1.tres"),
	preload("res://resources/attacks/fist_cross_2.tres"),
	preload("res://resources/attacks/fist_breaker_3.tres"),
]
const SKILL_ATTACK = preload("res://resources/attacks/fist_drive_step.tres")
const VISUAL_SCALE := 1.03
const ULTIMATE_STEP_INTERVAL := 0.085
const ULTIMATE_BLUE_HITBOX_SIZE := Vector2(168.0, 62.0)
const ULTIMATE_RED_HITBOX_SIZE := Vector2(188.0, 96.0)
const RANGED_MUZZLE_OFFSET := Vector2(16.0, -42.0)
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

@export var stats: CharacterStats = DEFAULT_STATS
@export var weapon_data: WeaponData = DEFAULT_WEAPON

@onready var visual_root: Node2D = $VisualRoot
@onready var animated_sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite
@onready var ranged_muzzle_anchor: Marker2D = $VisualRoot/RangedMuzzleAnchor
@onready var body: Polygon2D = $VisualRoot/FallbackRoot/Body
@onready var visor: Polygon2D = $VisualRoot/FallbackRoot/Visor
@onready var hitbox: Hitbox = $FacingPivot/Hitbox
@onready var hitbox_collision_shape: CollisionShape2D = $FacingPivot/Hitbox/CollisionShape2D
@onready var hurtbox = $Hurtbox
@onready var facing_pivot: Node2D = $FacingPivot
@onready var debug_label: Label = $DebugLabel
@onready var animation_controller: Node = $AnimationController

var _runtime_stats: CharacterStats
var _health: int = 1
var _energy: int = 1
var _facing: int = 1
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _attack_locked: bool = false
var _combo_index: int = 0
var _combo_reset_timer: float = 0.0
var _invulnerable_timer: float = 0.0
# Damage formula: final_damage = base_damage * item_mult * weapon_mult (see numerical_values.md)
var _item_damage_mult: float = 1.0
var _item_projectile_bounces: int = 0
var _weapon_damage_mult: float = 1.0
var _dead: bool = false
var _last_reported_combo: int = -1
var _skill_hold_timer: float = 0.0
var _skill_hold_active: bool = false
var _skill_hold_consumed: bool = false
var _ultimate_active: bool = false
var _default_hitbox_position: Vector2 = Vector2.ZERO
var _default_hitbox_size: Vector2 = Vector2.ZERO
var _previous_equipped_index: int = -1
var _weapon_charge_timer: float = 0.0
var _weapon_skill_ready: bool = false
var _last_attack_hit_targets: Array[Node] = []
var _weapon_skill_buff_timer: float = 0.0
var _weapon_skill_attack_speed_bonus: float = 1.0
var _bleed_targets: Dictionary = {}
var _ranged_shot_counter: int = 0
var _next_shot_empowered: bool = false
var _weapon_slot_shot_counter: Array[int] = [0, 0, 0]
var _weapon_slot_next_empowered: Array[bool] = [false, false, false]
var _weapon_skill_cooldown_timer: float = 0.0
var _weapon_pierce_timer: float = 0.0
var _enemy_kill_count: int = 0
var _attack_lunge_timer: float = 0.0
var _attack_lunge_duration: float = 0.0
var _attack_lunge_speed: float = 0.0
var _thunder_boss_bonus_stacks: int = 0
var inventory: Array[WeaponData] = [null, null, null]  # 3 weapon slots, null = fist
var equipped_index: int = 0  # 0, 1, 2; null slot means using fist
var accessory_inventory: Array[ItemData] = []
var _auto_fire_timer: float = 0.0
var _auto_firing: bool = false
var _ranged_attack_anim_playing: bool = false
var _ranged_attack_cooldown_timer: float = 0.0
var _ranged_attack_sequence: int = 0
var _ranged_ammo: int = 0
var _ranged_magazine_ammo: int = 0
var _weapon_slot_ammo: Array[int] = [0, 0, 0]
var _weapon_slot_magazine_ammo: Array[int] = [0, 0, 0]
var _reload_timer: float = 0.0
var _ranged_charge_timer: float = 0.0
var _ranged_charging: bool = false

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
	# All slots start as null (fist)
	equipped_index = 0
	_apply_equipped_weapon_modifiers()
	_report_weapon()
	GameEvents.report_player_combo(0, _attack_chain().size())
	hitbox.hit_landed.connect(_on_hit_landed)
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	_update_facing_visual()
	_update_movement_animation()


func _physics_process(delta: float) -> void:
	if _dead:
		_stop_auto_fire()
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

	if _attack_locked:
		_process_locked_attack_motion(delta)
		return

	var axis: float = Input.get_axis("move_left", "move_right")
	if not is_zero_approx(axis):
		_facing = 1 if axis > 0.0 else -1
		velocity.x = move_toward(velocity.x, axis * _runtime_stats.move_speed * _ranged_aim_move_scale(), _runtime_stats.acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * delta)

	if not is_on_floor():
		velocity.y += _gravity() * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = _runtime_stats.jump_velocity

	if Input.is_action_just_pressed("dash") and _dash_cooldown_timer <= 0.0:
		_start_dash()

	if Input.is_action_just_pressed("attack") and (not _weapon_is_ranged() or _weapon_trigger_mode() == &"semi_auto"):
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

	var next_health: int = max(0, _health - int(attack_data.damage))
	_invulnerable_timer = max(attack_data.hit_stun, 0.12)

	var knock_direction: int = facing
	if source != null:
		knock_direction = 1 if global_position.x >= source.global_position.x else -1
	velocity.x = attack_data.knockback.x * knock_direction
	velocity.y = attack_data.knockback.y
	_flash(Color(1.0, 0.18, 0.22, 1.0))

	if next_health <= 0:
		var revive_item: ItemData = _consume_best_revive_accessory()
		_health = 0
		GameEvents.report_player_health(_health, _runtime_stats.max_health)
		if revive_item != null:
			_revive_in_place(revive_item)
			return
		_revive_in_place(null)
		return

	_health = next_health
	GameEvents.report_player_health(_health, _runtime_stats.max_health)

	if _health <= 0:
		_die()
	else:
		animation_controller.play_action(&"hit")


func apply_item(item_data) -> bool:
	if item_data == null:
		return false

	if item_data.effect_id == &"revive_accessory":
		accessory_inventory.append(item_data)
		GameEvents.report_item_collected(item_data.item_id)
		GameEvents.request_toast("Accessory equipped: %s" % item_data.display_name)
		return true

	match item_data.effect_id:
		&"damage_multiplier":
			_item_damage_mult += item_data.magnitude
		&"heal":
			_health = min(_runtime_stats.max_health, _health + roundi(item_data.magnitude))
		&"dash_cooldown":
			_runtime_stats.dash_cooldown = max(0.12, _runtime_stats.dash_cooldown - item_data.magnitude)
		&"max_health":
			_runtime_stats.max_health += roundi(item_data.magnitude)
			_health = min(_runtime_stats.max_health, _health + roundi(item_data.magnitude))
		&"projectile_bounce":
			_item_projectile_bounces += item_data.bounce_count

	GameEvents.report_player_health(_health, _runtime_stats.max_health)
	GameEvents.report_item_collected(item_data.item_id)
	return true


func apply_weapon_pickup(wd: WeaponData) -> bool:
	if wd == null:
		return false

	# Find first empty slot (null)
	var empty_slot: int = -1
	for i in range(3):
		if inventory[i] == null:
			empty_slot = i
			break

	if empty_slot >= 0:
		# Found empty slot, place weapon there and equip it
		inventory[empty_slot] = wd
		_initialize_weapon_slot_ammo(empty_slot)
		_equip_inventory_slot(empty_slot)
	else:
		# All slots full, replace current equipped weapon
		var replaced: WeaponData = inventory[equipped_index]
		inventory[equipped_index] = wd
		_initialize_weapon_slot_ammo(equipped_index)
		_equip_inventory_slot(equipped_index, true)
		_spawn_dropped_weapon_pickup(replaced)
	return true


func _try_pickup_weapon() -> bool:
	var pickup := _nearest_weapon_pickup()
	if pickup != null:
		if pickup.try_pickup(self):
			get_viewport().set_input_as_handled()
			return true
	return false

func pickup_weapon() -> void:
	_try_pickup_weapon()


func has_weapon_pickup_priority() -> bool:
	var pickup := _nearest_weapon_pickup()
	return pickup != null and pickup.is_player_in_range(self)


func equip_weapon(index: int) -> void:
	_equip_inventory_slot(index)


func try_equip_slot(slot: int) -> void:
	# slot is 0-indexed (0=slot1, 1=slot2, 2=slot3)
	_equip_inventory_slot(slot)


func switch_previous_weapon() -> void:
	if _previous_equipped_index < 0 or _previous_equipped_index >= 3:
		return
	if _previous_equipped_index == equipped_index:
		return
	equip_weapon(_previous_equipped_index)


func drop_weapon() -> void:
	if inventory[equipped_index] == null:
		return

	var dropped: WeaponData = inventory[equipped_index]
	inventory[equipped_index] = null  # Replace with fist (empty slot)
	_weapon_slot_ammo[equipped_index] = 0
	_weapon_slot_magazine_ammo[equipped_index] = 0

	# Find next non-null slot to equip
	var next_index: int = -1
	for i in range(3):
		if inventory[i] != null:
			next_index = i
			break

	if next_index >= 0:
		_equip_inventory_slot(next_index, true)
	else:
		# All slots are null, switch to fist
		_equip_inventory_slot(0, true)
	_spawn_dropped_weapon_pickup(dropped)


func is_alive() -> bool:
	return not _dead


func sync_ranged_fire_input() -> void:
	_sync_ranged_attack_input()


func apply_ammo_pickup(amount: int) -> bool:
	if amount <= 0:
		return false
	if weapon_data == null or not _weapon_is_ranged():
		return false
	if weapon_data.ammo_capacity <= 0:
		return false

	var changed := false
	if weapon_data.ammo_capacity > 0:
		var current_total := _total_ammo_for_equipped_weapon()
		if current_total < weapon_data.ammo_capacity:
			var target_total := mini(weapon_data.ammo_capacity, current_total + amount)
			var current_mag := _ranged_magazine_ammo
			var reserve := maxi(0, target_total - current_mag)
			_ranged_ammo = reserve
			changed = true
	else:
		if weapon_data.magazine_size > 0 and _ranged_magazine_ammo < weapon_data.magazine_size:
			_ranged_magazine_ammo = mini(weapon_data.magazine_size, _ranged_magazine_ammo + amount)
			changed = true

	if not changed:
		return false

	_save_equipped_weapon_ammo_state()
	_report_ammo()
	GameEvents.request_toast("%s // +%d ammo" % [weapon_data.display_name, amount])
	return true


func _tick_timers(delta: float) -> void:
	_dash_timer = max(0.0, _dash_timer - delta)
	_dash_cooldown_timer = max(0.0, _dash_cooldown_timer - delta)
	_attack_lunge_timer = max(0.0, _attack_lunge_timer - delta)
	_ranged_attack_cooldown_timer = max(0.0, _ranged_attack_cooldown_timer - delta)
	_tick_ranged_reload(delta)
	_tick_ranged_charge(delta)
	_invulnerable_timer = max(0.0, _invulnerable_timer - delta)
	_combo_reset_timer = max(0.0, _combo_reset_timer - delta)
	_tick_weapon_charge(delta)
	_tick_weapon_skill_buff(delta)
	_tick_bleed_effects(delta)
	_tick_weapon_skill_cooldown(delta)
	_tick_weapon_pierce(delta)
	_tick_auto_fire(delta)
	if _combo_reset_timer <= 0.0 and _last_reported_combo != 0:
		_combo_index = 0
		_report_combo(0)


func _update_skill_input(delta: float) -> void:
	if weapon_data != null and weapon_data.skill_attack == null and weapon_data.skill_effect_id == &"none":
		_skill_hold_active = false
		_skill_hold_consumed = false
		_skill_hold_timer = 0.0
		return

	if Input.is_action_just_pressed("skill") and not _attack_locked:
		if _weapon_skill_uses_charge():
			_try_weapon_charge_skill()
			return
		_skill_hold_active = true
		_skill_hold_consumed = false
		_skill_hold_timer = 0.0

	if _skill_hold_active:
		_skill_hold_timer += delta
		if _weapon_has_ultimate() and _skill_hold_timer >= _ultimate_hold_time():
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
	# 如果 dash 打断了正在进行的攻击，取消攻击锁定以避免混合状态
	if _attack_locked:
		_attack_locked = false
		_stop_attack_lunge()
		animation_controller.clear_action()
	_dash_timer = _runtime_stats.dash_duration
	_dash_cooldown_timer = _runtime_stats.dash_cooldown
	_invulnerable_timer = max(_invulnerable_timer, _runtime_stats.dash_duration)
	animation_controller.play_state(&"combat_dash")
	GameEvents.request_vfx(&"dash_burst", global_position + Vector2(0.0, -28.0), _facing)
	GameEvents.request_camera_impulse(0.35, 0.04)


func _try_attack() -> void:
	if _attack_locked or _skill_hold_active:
		return

	if _weapon_is_ranged():
		if _ranged_attack_cooldown_timer > 0.0:
			return
		_try_ranged_attack()
		return

	var chain: Array = _attack_chain()
	if chain.is_empty():
		return

	var combo_step: int = _combo_index + 1
	var template: Resource = chain[_combo_index]
	_combo_index = (_combo_index + 1) % chain.size()
	_combo_reset_timer = 0.72
	_report_combo(combo_step)
	_start_attack(template)


func _try_skill() -> void:
	if weapon_data != null and weapon_data.weapon_id == &"reverse_charge_katana" and _weapon_skill_uses_charge():
		_try_reverse_charge_katana_skill()
		return
	if weapon_data != null and weapon_data.skill_effect_id == &"stiletto_overclock":
		_try_stiletto_overclock()
		return
	if weapon_data != null and weapon_data.skill_effect_id == &"next_gen_energy_burst":
		_try_next_gen_energy_burst()
		return
	if weapon_data != null and weapon_data.skill_effect_id == &"surge_armor_pierce":
		_try_surge_armor_pierce()
		return

	var skill_attack: Resource = _skill_attack()
	if skill_attack == null:
		GameEvents.request_toast("%s // offline" % _skill_name())
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
	GameEvents.request_vfx(&"skill_cast_default", global_position + Vector2(0.0, -30.0), _facing)
	GameEvents.request_toast("%s // execution window" % _skill_name())
	_start_attack(skill_attack)


func _start_attack(template: Resource) -> void:
	_attack_locked = true
	_last_attack_hit_targets.clear()
	var attack: Resource = template.duplicate(true)
	attack.damage = max(1, roundi(float(attack.damage) * _item_damage_mult * _weapon_damage_scale()))
	attack.cooldown = max(0.04, attack.cooldown / _weapon_attack_speed_scale())
	_update_facing_visual()
	var action_id: StringName = _resolve_attack_animation(attack)
	animation_controller.play_action(action_id)
	_restore_hitbox()
	hitbox.activate(attack, self, _facing)

	var lock_duration: float = _attack_lock_duration(attack, action_id)
	_start_attack_lunge(attack, lock_duration)
	await get_tree().create_timer(lock_duration).timeout
	# dash 可能在 await 期间被触发，此时不要覆盖 dash 状态
	if _dash_timer > 0.0:
		return
	_attack_locked = false
	_stop_attack_lunge()
	animation_controller.clear_action()
	_update_movement_animation()


func _process_locked_attack_motion(delta: float) -> void:
	if _attack_lunge_timer > 0.0:
		velocity.x = _facing * _attack_lunge_speed
	else:
		velocity.x = 0.0
	if not is_on_floor():
		velocity.y += _gravity() * delta
	move_and_slide()
	_update_facing_visual()
	_update_debug_label()


func _start_attack_lunge(attack, lock_duration: float) -> void:
	var lunge_distance := 0.0
	if attack != null and attack.get("lunge") != null:
		lunge_distance = max(0.0, float(attack.lunge))

	if lunge_distance <= 0.0 or lock_duration <= 0.0:
		_stop_attack_lunge()
		return

	_attack_lunge_duration = clamp(lock_duration * 0.32, 0.07, 0.14)
	_attack_lunge_timer = _attack_lunge_duration
	_attack_lunge_speed = lunge_distance / _attack_lunge_duration


func _stop_attack_lunge() -> void:
	_attack_lunge_timer = 0.0
	_attack_lunge_duration = 0.0
	_attack_lunge_speed = 0.0
	velocity.x = 0.0


func _start_ultimate() -> void:
	var attacks: Array = _ultimate_attacks()
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


func _on_enemy_defeated(_enemy_id: StringName) -> void:
	_enemy_kill_count += 1


func _apply_hit_stop(duration: float) -> void:
	if duration <= 0.0:
		return

	var previous_scale: float = Engine.time_scale
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
		animation_controller.play_state(&"combat_dash")
	elif not is_on_floor():
		if velocity.y < 0.0:
			animation_controller.play_state(&"combat_jump")
		else:
			animation_controller.play_state(&"combat_fall")
	elif absf(velocity.x) > 4.0:
		animation_controller.play_state(&"combat_run")
	else:
		animation_controller.play_state(&"combat_idle")


func _update_debug_label() -> void:
	if debug_label == null or not debug_label.visible:
		return
	var state: String = "AIR"
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
	return "Yuan Jie"


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
	if weapon_data != null:
		return (
			not _attack_locked
			and not _ultimate_active
			and _energy >= _ultimate_cost()
			and weapon_data.has_method("has_ultimate")
			and weapon_data.has_ultimate()
		)
	else:
		# Fist ultimate
		return (
			not _attack_locked
			and not _ultimate_active
			and _energy >= _runtime_stats.max_energy
		)


func _report_weapon() -> void:
	GameEvents.report_player_weapon(weapon_data)
	GameEvents.report_player_weapon_slots(inventory[0], inventory[1], inventory[2], equipped_index)
	_report_ammo()
	if weapon_data != null:
		if weapon_data.has_method("has_ultimate") and weapon_data.has_ultimate():
			GameEvents.report_player_ultimate(_ultimate_name(), _ultimate_cost(), _ultimate_hold_time())
		else:
			GameEvents.report_player_ultimate("--", 0, 0.0)
	else:
		# Fist has ultimate
		GameEvents.report_player_ultimate("Yuan Jie", _runtime_stats.max_energy, 0.45)


func _report_combo(combo_step: int) -> void:
	if _last_reported_combo == combo_step:
		return
	_last_reported_combo = combo_step
	GameEvents.report_player_combo(combo_step, _attack_chain().size())


func _prepare_hitbox_shape() -> void:
	_default_hitbox_position = hitbox.position
	var rect: RectangleShape2D = hitbox_collision_shape.shape as RectangleShape2D
	if rect == null:
		return

	hitbox_collision_shape.shape = rect.duplicate()
	rect = hitbox_collision_shape.shape as RectangleShape2D
	_default_hitbox_size = rect.size


func _configure_hitbox(local_position: Vector2, size: Vector2) -> void:
	hitbox.position = local_position
	var rect: RectangleShape2D = hitbox_collision_shape.shape as RectangleShape2D
	if rect != null:
		rect.size = size


func _restore_hitbox() -> void:
	hitbox.position = _default_hitbox_position
	var rect: RectangleShape2D = hitbox_collision_shape.shape as RectangleShape2D
	if rect != null and _default_hitbox_size != Vector2.ZERO:
		rect.size = _default_hitbox_size


func _show_visual(is_visible: bool) -> void:
	visual_root.visible = is_visible


func _flash(color: Color) -> void:
	animated_sprite.modulate = color
	body.modulate = color
	visor.modulate = Color.WHITE
	var tween: Tween = create_tween()
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


func _consume_best_revive_accessory() -> ItemData:
	var selected_index: int = -1
	var selected_priority: int = -999999
	for index in range(accessory_inventory.size()):
		var item: ItemData = accessory_inventory[index]
		if item == null or item.effect_id != &"revive_accessory":
			continue
		if selected_index < 0 or item.revive_priority > selected_priority:
			selected_index = index
			selected_priority = item.revive_priority
	if selected_index < 0:
		return null

	var selected_item: ItemData = accessory_inventory[selected_index]
	accessory_inventory.remove_at(selected_index)
	return selected_item


func _revive_in_place(item_data: ItemData) -> void:
	_dead = true
	hitbox.deactivate()
	body.modulate = Color(0.22, 0.22, 0.28, 1.0)
	animation_controller.play_action(&"death")
	if debug_label != null and debug_label.visible:
		debug_label.text = "OFFLINE"
	GameEvents.request_camera_impulse(1.2, 0.18)
	call_deferred("_finish_revive_in_place", item_data)


func _finish_revive_in_place(item_data: ItemData) -> void:
	var revive_delay: float = 0.9
	if item_data != null:
		revive_delay = maxf(revive_delay, item_data.revive_delay)
	await get_tree().create_timer(revive_delay, true, false, true).timeout
	if is_inside_tree():
		GameEvents.request_run_reset()


func _resolve_attack_animation(attack) -> StringName:
	if attack != null and attack.has_method("resolved_animation_id"):
		return attack.resolved_animation_id()
	if attack != null:
		return attack.attack_id
	return &"punch_1"


func _attack_lock_duration(attack, action_id: StringName) -> float:
	var cooldown: float = 0.0
	if attack != null and attack.get("cooldown") != null:
		cooldown = float(attack.cooldown)

	if animation_controller != null and animation_controller.has_method("animation_duration_for"):
		var animation_duration: float = float(animation_controller.animation_duration_for(action_id))
		if animation_duration > 0.0:
			return max(cooldown, animation_duration)

	return cooldown


func _gravity() -> float:
	return ProjectSettings.get_setting("physics/2d/default_gravity") * _runtime_stats.gravity_scale


func _handle_weapon_input() -> void:
	if Input.is_action_just_pressed("reload") and _weapon_is_ranged():
		_try_start_reload()

	if Input.is_action_just_pressed("drop_weapon"):
		drop_weapon()

	if Input.is_action_just_pressed("interact"):
		if _try_pickup_weapon():
			return
		_try_world_interaction()

	if Input.is_action_just_pressed("weapon_slot_1"):
		try_equip_slot(0)
	if Input.is_action_just_pressed("weapon_slot_2"):
		try_equip_slot(1)
	if Input.is_action_just_pressed("weapon_slot_3"):
		try_equip_slot(2)
	if Input.is_action_just_pressed("switch_previous_weapon"):
		switch_previous_weapon()


func _sync_ranged_attack_input() -> void:
	if not _weapon_is_ranged():
		_stop_auto_fire()
		_cancel_ranged_charge()
		return

	if _weapon_trigger_mode() == &"charge":
		if Input.is_action_just_pressed("attack"):
			_start_ranged_charge()
		if Input.is_action_just_released("attack"):
			_release_ranged_charge()
		return

	if _weapon_trigger_mode() == &"auto" and Input.is_action_pressed("attack"):
		if not _auto_firing and Input.is_action_just_pressed("attack") and _ranged_attack_cooldown_timer <= 0.0:
			_try_attack()
		_auto_firing = true
		return

	if _auto_firing:
		_stop_auto_fire()


func _stop_auto_fire() -> void:
	_auto_firing = false
	_auto_fire_timer = 0.0
	if _ranged_attack_cooldown_timer <= 0.0 and _ranged_attack_anim_playing:
		animation_controller.clear_action()
		_update_movement_animation()
		_ranged_attack_anim_playing = false


func _apply_equipped_weapon_modifiers() -> void:
	_stop_auto_fire()
	# item multiplier persists across weapon swaps — do not reset
	_runtime_stats.move_speed = stats.move_speed
	_runtime_stats.max_health = stats.max_health
	_weapon_charge_timer = 0.0
	_weapon_skill_ready = false
	_weapon_skill_buff_timer = 0.0
	_weapon_skill_attack_speed_bonus = 1.0
	_ranged_shot_counter = 0
	_next_shot_empowered = false
	_weapon_skill_cooldown_timer = 0.0
	_weapon_pierce_timer = 0.0
	_thunder_boss_bonus_stacks = 0
	_reload_timer = 0.0
	_ranged_charge_timer = 0.0
	_ranged_charging = false
	_last_attack_hit_targets.clear()
	_bleed_targets.clear()
	if weapon_data == null:
		_ranged_ammo = 0
		_ranged_magazine_ammo = 0
		_health = min(_health, _runtime_stats.max_health)
		GameEvents.report_player_health(_health, _runtime_stats.max_health)
		_report_ammo()
		return
	_restore_equipped_weapon_ammo_state()
	_restore_equipped_weapon_passive_state()
	_runtime_stats.move_speed = stats.move_speed * weapon_data.equip_move_speed_scale
	_runtime_stats.max_health = max(1, roundi(float(stats.max_health) * weapon_data.equip_max_health_scale))
	_health = min(_health, _runtime_stats.max_health)
	_apply_elemental_self_modifiers()
	GameEvents.report_player_health(_health, _runtime_stats.max_health)
	_report_ammo()


func _weapon_damage_scale() -> float:
	if weapon_data == null:
		return 1.0
	return weapon_data.attack_damage_scale


func _weapon_attack_speed_scale() -> float:
	if weapon_data == null:
		return 1.0
	return maxf(0.1, weapon_data.attack_speed_scale * _weapon_skill_attack_speed_bonus)


func _weapon_is_ranged() -> bool:
	return weapon_data != null and (weapon_data.attack_mode == &"hitscan" or weapon_data.attack_mode == &"projectile")


func _weapon_uses_projectile() -> bool:
	return weapon_data != null and weapon_data.attack_mode == &"projectile"


func _weapon_trigger_mode() -> StringName:
	if weapon_data == null:
		return &"semi_auto"
	return weapon_data.trigger_mode


func _weapon_fire_pattern() -> StringName:
	if weapon_data == null:
		return &"single"
	return weapon_data.fire_pattern


func _weapon_has_ultimate() -> bool:
	return weapon_data != null and weapon_data.has_method("has_ultimate") and weapon_data.has_ultimate()


func _nearest_weapon_pickup() -> WeaponPickup:
	var nearest: WeaponPickup = null
	var nearest_distance := INF
	for node in get_tree().get_nodes_in_group("weapon_pickups"):
		var pickup := node as WeaponPickup
		if pickup == null or not is_instance_valid(pickup):
			continue
		var distance := global_position.distance_squared_to(pickup.global_position)
		if distance < nearest_distance:
			nearest = pickup
			nearest_distance = distance
	return nearest


func _try_world_interaction() -> bool:
	var interactable := _nearest_demo_interactable()
	if interactable == null:
		return false
	if interactable.try_interact(self):
		get_viewport().set_input_as_handled()
		return true
	return false


func _nearest_demo_interactable() -> DemoInteractable:
	var nearest: DemoInteractable = null
	var nearest_distance := INF
	for node in get_tree().get_nodes_in_group("demo_interactables"):
		var interactable := node as DemoInteractable
		if interactable == null or not is_instance_valid(interactable):
			continue
		if not interactable.can_interact(self):
			continue
		var distance := global_position.distance_squared_to(interactable.global_position)
		if distance < nearest_distance:
			nearest = interactable
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
		and (weapon_data.weapon_id == &"reverse_charge_katana" or _skill_attack() != null)
	)


func _try_ranged_attack() -> void:
	if not _can_fire_ranged_weapon():
		return
	var template: Resource = _attack_chain().front()
	if template == null:
		return
	_last_attack_hit_targets.clear()
	var attack = template.duplicate(true)
	attack.damage = max(1, roundi(float(attack.damage) * _item_damage_mult * _weapon_damage_scale()))
	attack.cooldown = _get_weapon_fire_interval()
	_ranged_attack_cooldown_timer = attack.cooldown
	_ranged_attack_sequence += 1
	var shot_sequence := _ranged_attack_sequence
	_consume_ranged_ammo()

	if not _ranged_attack_anim_playing:
		_ranged_attack_anim_playing = true
		animation_controller.play_action(_resolve_attack_animation(attack))

	var aim_facing := _aim_facing_for(get_global_mouse_position() - global_position)
	if aim_facing != _facing:
		_facing = aim_facing
		_update_facing_visual()
	var muzzle_position := _ranged_muzzle_position()
	var aim_direction := _aim_direction_from(muzzle_position)
	var empowered := false
	if weapon_data == null or weapon_data.passive_effect_id != &"next_gen_shock_round":
		empowered = _consume_empowered_shot()
	var damage_scale := _consume_charge_damage_scale()
	if damage_scale > 1.0:
		attack.damage = max(1, roundi(float(attack.damage) * damage_scale))

	match _weapon_fire_pattern():
		&"burst":
			_fire_burst_attack(attack, aim_direction, empowered)
		&"spread":
			_fire_spread_attack(attack, aim_direction, empowered)
		_:
			_fire_single_ranged_attack(attack, aim_direction, empowered)

	_apply_ranged_recoil(aim_direction)

	_clear_ranged_attack_action_when_ready(shot_sequence, attack.cooldown)


func _fire_hitscan_attack(attack_data: AttackData, aim_direction: Vector2, empowered: bool = false) -> void:
	var start := _ranged_muzzle_position()
	var end := start + aim_direction * _weapon_ranged_range()
	GameEvents.request_vfx(&"dash_burst", start + aim_direction * 16.0, _facing)
	GameEvents.request_sfx(attack_data.sfx_id, start)
	if empowered:
		GameEvents.request_toast("%s // shock round" % weapon_data.display_name)
	var hits := _collect_hitscan_targets(start, end, _weapon_current_pierce_count())
	if hits.is_empty():
		GameEvents.request_camera_impulse(0.12, 0.02)
		return

	if empowered:
		var first_hit: Dictionary = hits.front()
		_apply_next_gen_empowered_hit(first_hit.get("target"), attack_data, first_hit.get("position", end))
		return

	var last_position: Vector2 = end
	var hit_any := false
	for hit in hits:
		var area := hit.get("area") as Area2D
		var target: Node = hit.get("target")
		var position: Vector2 = hit.get("position", end)
		if area == null or target == null:
			continue
		last_position = position
		area.call("receive_hit", attack_data, self, position, _facing)
		var is_new_target := _register_attack_target_hit(target)
		_apply_weapon_passive_on_hit(target, attack_data, is_new_target)
		hit_any = true

	if attack_data.energy_regen > 0 and hit_any:
		_energy = min(_runtime_stats.max_energy, _energy + int(attack_data.energy_regen))
		GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
	if hit_any:
		GameEvents.request_vfx(attack_data.vfx_id, last_position, _facing)
		GameEvents.request_camera_impulse(attack_data.screen_shake, 0.04)
		_apply_hit_stop(attack_data.hit_stop)
	else:
		GameEvents.request_camera_impulse(0.12, 0.02)


func _fire_single_ranged_attack(attack_data: AttackData, aim_direction: Vector2, empowered: bool = false) -> void:
	_register_ranged_projectile_fired()
	if _weapon_uses_projectile():
		_fire_projectile_attack(attack_data, aim_direction, empowered)
	else:
		_fire_hitscan_attack(attack_data, aim_direction, empowered)


func _fire_burst_attack(attack_data: AttackData, aim_direction: Vector2, empowered: bool = false) -> void:
	var count := maxi(1, weapon_data.burst_count if weapon_data != null else 1)
	var interval := maxf(0.01, weapon_data.burst_interval if weapon_data != null else 0.06)
	var first_empowered := empowered
	if weapon_data != null and weapon_data.passive_effect_id == &"next_gen_shock_round":
		first_empowered = _consume_empowered_shot()
	_fire_single_ranged_attack(attack_data, aim_direction, first_empowered)
	if count <= 1:
		return
	_fire_burst_followups(attack_data, aim_direction, count - 1, interval)


func _fire_burst_followups(attack_data: AttackData, aim_direction: Vector2, remaining: int, interval: float) -> void:
	var shots_left := remaining
	while shots_left > 0:
		await get_tree().create_timer(interval).timeout
		if not is_inside_tree() or _dead or _ultimate_active:
			return
		var shot_empowered := false
		if weapon_data != null and weapon_data.passive_effect_id == &"next_gen_shock_round":
			shot_empowered = _consume_empowered_shot()
		_fire_single_ranged_attack(attack_data.duplicate(true), aim_direction, shot_empowered)
		shots_left -= 1


func _fire_spread_attack(attack_data: AttackData, aim_direction: Vector2, empowered: bool = false) -> void:
	var pellet_total := maxi(1, weapon_data.pellet_count if weapon_data != null else 1)
	if pellet_total <= 1:
		_fire_single_ranged_attack(attack_data, aim_direction, empowered)
		return
	var spread_radians := deg_to_rad(maxf(0.0, weapon_data.spread_angle_degrees if weapon_data != null else 0.0))
	var start_angle := -spread_radians * 0.5
	var step := spread_radians / float(maxi(1, pellet_total - 1))
	for index in range(pellet_total):
		var pellet_attack = attack_data.duplicate(true)
		pellet_attack.damage = max(1, roundi(float(pellet_attack.damage) / sqrt(float(pellet_total))))
		var rotated_direction := aim_direction.rotated(start_angle + step * float(index)).normalized()
		_fire_single_ranged_attack(pellet_attack, rotated_direction, empowered and index == pellet_total / 2)


func _weapon_ranged_range() -> float:
	if weapon_data == null:
		return 520.0
	return maxf(120.0, weapon_data.ranged_range)


func _weapon_current_pierce_count() -> int:
	if weapon_data == null:
		return 1
	if _weapon_pierce_timer > 0.0:
		return maxi(1, weapon_data.ranged_pierce_count)
	return 1


func _fire_projectile_attack(attack_data: AttackData, aim_direction: Vector2, empowered: bool = false) -> void:
	var spawn_pos := _ranged_muzzle_position()
	var projectile = PROJECTILE_SCENE.instantiate() as Projectile
	if projectile == null:
		return

	var pierce := _weapon_current_pierce_count()
	if empowered:
		pierce = maxi(pierce, 5)  # 冲击波弹额外穿透

	projectile.fire(
		attack_data,
		self,
		aim_direction,
		_facing,
		_weapon_projectile_speed(),
		_weapon_projectile_lifetime(),
		pierce,
		_item_projectile_bounces
	)
	projectile.global_position = spawn_pos

	# 应用武器自定义子弹颜色
	if weapon_data != null:
		projectile.configure_visual(
			weapon_data.projectile_size,
			weapon_data.projectile_color,
			empowered,
			weapon_data.projectile_texture
		)

	# 将子弹添加到当前场景
	var parent := get_parent()
	if parent == null:
		parent = get_tree().current_scene
	if parent != null:
		parent.add_child(projectile)

	# 命中信号连接（用于能量回复等）
	projectile.hit_target.connect(_on_projectile_hit_target)

	if empowered:
		GameEvents.request_toast("%s // shock round" % weapon_data.display_name)

	# 枪口闪光 VFX
	GameEvents.request_vfx(&"dash_burst", spawn_pos + aim_direction * 16.0, _facing)
	GameEvents.request_sfx(attack_data.sfx_id, spawn_pos)
	GameEvents.request_camera_impulse(0.12, 0.02)


func _on_projectile_hit_target(target: Node, attack_data: AttackData, hit_position: Vector2, was_empowered: bool) -> void:
	if target == null or not is_instance_valid(target):
		return
	if was_empowered and weapon_data != null and weapon_data.passive_effect_id == &"next_gen_shock_round":
		_apply_next_gen_empowered_hit(target, attack_data, hit_position)
		return
	var is_new_target := _register_attack_target_hit(target)
	_apply_weapon_passive_on_hit(target, attack_data, is_new_target)
	if attack_data.energy_regen > 0:
		_energy = min(_runtime_stats.max_energy, _energy + int(attack_data.energy_regen))
		GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)


func _weapon_projectile_speed() -> float:
	if weapon_data == null:
		return 800.0
	return maxf(200.0, weapon_data.projectile_speed)


func _weapon_projectile_lifetime() -> float:
	if weapon_data == null:
		return 1.5
	return maxf(0.3, weapon_data.projectile_lifetime)


func _reset_ranged_ammo_for_weapon() -> void:
	if weapon_data == null or not _weapon_is_ranged():
		_ranged_ammo = 0
		_ranged_magazine_ammo = 0
		return
	_ranged_ammo = maxi(0, weapon_data.ammo_capacity)
	if weapon_data.magazine_size > 0:
		if weapon_data.ammo_capacity <= 0:
			_ranged_magazine_ammo = weapon_data.magazine_size
		else:
			_ranged_magazine_ammo = mini(weapon_data.magazine_size, _ranged_ammo)
			_ranged_ammo -= _ranged_magazine_ammo
	else:
		_ranged_magazine_ammo = 0
	_save_equipped_weapon_ammo_state()


func _report_ammo() -> void:
	if weapon_data == null or not _weapon_is_ranged():
		GameEvents.report_player_ammo(0, 0, 0, 0, false)
		return
	GameEvents.report_player_ammo(_ranged_ammo, weapon_data.ammo_capacity, _ranged_magazine_ammo, weapon_data.magazine_size, _reload_timer > 0.0)


func _can_fire_ranged_weapon() -> bool:
	if weapon_data == null:
		return false
	if _reload_timer > 0.0:
		return false
	if weapon_data.magazine_size > 0:
		if _ranged_magazine_ammo > 0:
			return true
		_try_start_reload()
		return false
	if weapon_data.ammo_capacity <= 0:
		return true
	if _ranged_ammo > 0:
		return true
	GameEvents.request_toast("%s // ammo depleted" % weapon_data.display_name)
	_report_ammo()
	return false


func _consume_ranged_ammo() -> void:
	if weapon_data == null:
		return
	if weapon_data.magazine_size > 0:
		_ranged_magazine_ammo = maxi(0, _ranged_magazine_ammo - 1)
		_save_equipped_weapon_ammo_state()
		_report_ammo()
		if _ranged_magazine_ammo <= 0:
			_try_start_reload()
		return
	if weapon_data.ammo_capacity > 0:
		_ranged_ammo = maxi(0, _ranged_ammo - 1)
		_save_equipped_weapon_ammo_state()
		_report_ammo()


func _try_start_reload() -> void:
	if weapon_data == null or weapon_data.magazine_size <= 0 or _reload_timer > 0.0:
		return
	if _ranged_magazine_ammo >= weapon_data.magazine_size:
		return
	if weapon_data.ammo_capacity > 0 and _ranged_ammo <= 0:
		GameEvents.request_toast("%s // ammo depleted" % weapon_data.display_name)
		_report_ammo()
		return
	_reload_timer = maxf(0.05, weapon_data.reload_time)
	GameEvents.request_toast("%s // reloading" % weapon_data.display_name)
	_report_ammo()


func _tick_ranged_reload(delta: float) -> void:
	if _reload_timer <= 0.0:
		return
	_reload_timer = maxf(0.0, _reload_timer - delta)
	if _reload_timer > 0.0:
		return
	if weapon_data == null or weapon_data.magazine_size <= 0:
		_report_ammo()
		return
	var missing := maxi(0, weapon_data.magazine_size - _ranged_magazine_ammo)
	if weapon_data.ammo_capacity <= 0:
		_ranged_magazine_ammo = weapon_data.magazine_size
	else:
		var loaded := mini(missing, _ranged_ammo)
		_ranged_magazine_ammo += loaded
		_ranged_ammo -= loaded
	_save_equipped_weapon_ammo_state()
	_report_ammo()


func _start_ranged_charge() -> void:
	if _reload_timer > 0.0 or _ranged_attack_cooldown_timer > 0.0:
		return
	if not _can_fire_ranged_weapon():
		return
	_ranged_charging = true
	_ranged_charge_timer = 0.0
	GameEvents.request_toast("%s // charging" % weapon_data.display_name)


func _release_ranged_charge() -> void:
	if not _ranged_charging:
		return
	_ranged_charging = false
	_try_attack()


func _cancel_ranged_charge() -> void:
	_ranged_charging = false
	_ranged_charge_timer = 0.0


func _tick_ranged_charge(delta: float) -> void:
	if not _ranged_charging:
		return
	_ranged_charge_timer += delta


func _consume_charge_damage_scale() -> float:
	if weapon_data == null or weapon_data.trigger_mode != &"charge":
		return 1.0
	var required := maxf(0.01, weapon_data.charge_time)
	var ratio := clampf(_ranged_charge_timer / required, 0.0, 1.0)
	var scale := lerpf(1.0, maxf(1.0, weapon_data.charge_damage_scale), ratio)
	_ranged_charge_timer = 0.0
	return scale


func _apply_ranged_recoil(aim_direction: Vector2) -> void:
	if weapon_data == null or weapon_data.recoil_impulse <= 0.0:
		return
	velocity -= aim_direction.normalized() * weapon_data.recoil_impulse


func _ranged_aim_move_scale() -> float:
	if weapon_data == null or not _weapon_is_ranged():
		return 1.0
	if Input.is_action_pressed("attack"):
		return clampf(weapon_data.aim_move_speed_scale, 0.2, 1.4)
	return 1.0


func _tick_auto_fire(delta: float) -> void:
	if not _auto_firing:
		return
	if _ultimate_active or _dash_timer > 0.0:
		return
	if weapon_data == null:
		return  # 拳头不用自动开火
	# 近战武器不自动开火
	if weapon_data.weapon_type != &"ranged" and weapon_data.attack_mode != &"projectile":
		return

	if _ranged_attack_cooldown_timer > 0.0:
		return
	_try_attack()


func _equipped_weapon_slot_index() -> int:
	if equipped_index < 0 or equipped_index >= inventory.size():
		return -1
	return equipped_index


func _equip_inventory_slot(slot: int, force_refresh: bool = false) -> bool:
	if slot < 0 or slot >= inventory.size():
		return false
	var next_weapon: WeaponData = inventory[slot]
	if not force_refresh and equipped_index == slot and weapon_data == next_weapon:
		return false
	if equipped_index != slot:
		_previous_equipped_index = equipped_index
	equipped_index = slot
	weapon_data = next_weapon
	_apply_equipped_weapon_modifiers()
	_report_weapon()
	return true


func _initialize_weapon_slot_ammo(slot: int) -> void:
	if slot < 0 or slot >= inventory.size():
		return
	var slot_weapon := inventory[slot]
	if slot_weapon == null or slot_weapon.weapon_type != &"ranged":
		_weapon_slot_ammo[slot] = 0
		_weapon_slot_magazine_ammo[slot] = 0
		return
	if slot_weapon.magazine_size > 0:
		_weapon_slot_magazine_ammo[slot] = slot_weapon.magazine_size
		_weapon_slot_ammo[slot] = maxi(0, slot_weapon.ammo_capacity - _weapon_slot_magazine_ammo[slot])
	else:
		_weapon_slot_magazine_ammo[slot] = 0
		_weapon_slot_ammo[slot] = maxi(0, slot_weapon.ammo_capacity)


func _restore_equipped_weapon_ammo_state() -> void:
	var slot := _equipped_weapon_slot_index()
	if slot < 0 or weapon_data == null or not _weapon_is_ranged():
		_ranged_ammo = 0
		_ranged_magazine_ammo = 0
		return
	var has_saved_state := _weapon_slot_ammo[slot] > 0 or _weapon_slot_magazine_ammo[slot] > 0
	if not has_saved_state:
		_initialize_weapon_slot_ammo(slot)
	_ranged_ammo = _weapon_slot_ammo[slot]
	_ranged_magazine_ammo = _weapon_slot_magazine_ammo[slot]


func _save_equipped_weapon_ammo_state() -> void:
	var slot := _equipped_weapon_slot_index()
	if slot < 0:
		return
	_weapon_slot_ammo[slot] = _ranged_ammo
	_weapon_slot_magazine_ammo[slot] = _ranged_magazine_ammo


func _total_ammo_for_equipped_weapon() -> int:
	return _ranged_ammo + _ranged_magazine_ammo


func _ranged_muzzle_position() -> Vector2:
	if ranged_muzzle_anchor != null:
		return ranged_muzzle_anchor.global_position
	return global_position + Vector2(_facing * RANGED_MUZZLE_OFFSET.x, RANGED_MUZZLE_OFFSET.y)


func _aim_direction_from(origin: Vector2) -> Vector2:
	var direction := get_global_mouse_position() - origin
	if direction.length_squared() <= 0.0001:
		return Vector2(_facing, 0.0)
	return direction.normalized()


func _aim_facing_for(direction: Vector2) -> int:
	if absf(direction.x) <= 0.001:
		return _facing
	return 1 if direction.x > 0.0 else -1


func _clear_ranged_attack_action_when_ready(shot_sequence: int, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if shot_sequence != _ranged_attack_sequence:
		return
	if _auto_firing:
		return
	animation_controller.clear_action()
	_update_movement_animation()
	_ranged_attack_anim_playing = false


func _get_weapon_fire_interval() -> float:
	if weapon_data == null:
		return 0.2
	# 远程武器只按 weapon.md 的攻速等级控制开火频率，避免资源冷却和 scale 双重叠加。
	var speed_factor := maxf(0.1, weapon_data.attack_speed_rating / 100.0)
	return max(0.08, 0.3 / speed_factor)


func _consume_empowered_shot() -> bool:
	if weapon_data == null:
		return false
	var empowered := _next_shot_empowered
	if empowered:
		_next_shot_empowered = false
		_save_equipped_weapon_passive_state()
	return empowered


func _register_attack_target_hit(target: Node) -> bool:
	if target == null:
		return false
	if _last_attack_hit_targets.has(target):
		return false
	_last_attack_hit_targets.append(target)
	return true


func _try_weapon_charge_skill() -> void:
	if not _weapon_skill_ready:
		var remain := maxf(0.0, weapon_data.skill_charge_time - _weapon_charge_timer)
		GameEvents.request_toast("%s charging // %.1fs" % [_skill_name(), remain])
		return
	_weapon_skill_ready = false
	_weapon_charge_timer = 0.0
	_try_skill()


func _apply_weapon_passive_on_hit(target: Node, attack_data, is_new_target: bool = true) -> void:
	if weapon_data == null or target == null:
		return
	match weapon_data.passive_effect_id:
		&"katana_execute":
			_apply_katana_execute_passive(target, attack_data)
		&"stiletto_bleed":
			_apply_stiletto_bleed(target, attack_data)
		&"surge_health_wave":
			if is_new_target:
				_apply_surge_health_wave(target, attack_data)
	_apply_elemental_on_hit(target, attack_data, target.global_position if target is Node2D else global_position)


func _register_ranged_projectile_fired() -> void:
	if weapon_data == null:
		return
	if weapon_data.passive_effect_id != &"next_gen_shock_round":
		return
	if _next_shot_empowered:
		_save_equipped_weapon_passive_state()
		return
	_ranged_shot_counter += 1
	if _ranged_shot_counter >= weapon_data.passive_threshold:
		_ranged_shot_counter = 0
		_next_shot_empowered = true
		GameEvents.request_toast("%s // shock round loaded" % weapon_data.display_name)
	_save_equipped_weapon_passive_state()


func _apply_katana_execute_passive(target: Node, attack_data) -> void:
	if weapon_data == null:
		return
	if not target.has_method("apply_hit"):
		return
	var is_boss: bool = target.has_method("is_boss_enemy") and bool(target.is_boss_enemy())
	if is_boss:
		var bonus_attack = attack_data.duplicate(true)
		bonus_attack.damage = max(1, roundi(float(attack_data.damage) * weapon_data.passive_boss_damage_scale))
		target.apply_hit(bonus_attack, self, global_position, _facing)
		GameEvents.request_toast("%s // boss break" % weapon_data.display_name)
		return
	if _last_attack_hit_targets.size() <= weapon_data.passive_threshold:
		return
	if target.has_method("health_ratio") and target.health_ratio() <= weapon_data.passive_execute_health_ratio:
		var execute_attack = attack_data.duplicate(true)
		execute_attack.damage = 999999
		target.apply_hit(execute_attack, self, global_position, _facing)
		GameEvents.request_toast("%s // execute" % weapon_data.display_name)


func _apply_stiletto_bleed(target: Node, attack_data) -> void:
	if weapon_data == null or target == null:
		return
	var key := target.get_instance_id()
	var base_damage: int = int(attack_data.damage)
	if _bleed_targets.has(key):
		var existing: Dictionary = _bleed_targets[key]
		existing["target"] = target
		existing["stacks"] = int(existing.get("stacks", 0)) + 1
		existing["time_left"] = weapon_data.passive_bleed_duration
		existing["tick_timer"] = 1.0
		existing["base_damage"] = maxi(int(existing.get("base_damage", 0)), base_damage)
		_bleed_targets[key] = existing
	else:
		_bleed_targets[key] = {
			"target": target,
			"stacks": 1,
			"time_left": weapon_data.passive_bleed_duration,
			"tick_timer": 1.0,
			"base_damage": base_damage,
		}


func _tick_weapon_skill_buff(delta: float) -> void:
	if _weapon_skill_buff_timer <= 0.0:
		return
	_weapon_skill_buff_timer = maxf(0.0, _weapon_skill_buff_timer - delta)
	if _weapon_skill_buff_timer <= 0.0:
		_weapon_skill_attack_speed_bonus = 1.0
		GameEvents.request_toast("%s // offline" % _skill_name())


func _try_stiletto_overclock() -> void:
	if weapon_data == null:
		return
	if _weapon_skill_buff_timer > 0.0:
		GameEvents.request_toast("%s // active" % _skill_name())
		return
	_weapon_skill_attack_speed_bonus = maxf(1.0, weapon_data.skill_attack_speed_multiplier)
	_weapon_skill_buff_timer = maxf(0.0, weapon_data.skill_duration)
	GameEvents.request_vfx(&"skill_stiletto_overclock", global_position + Vector2(0.0, -30.0), _facing)
	GameEvents.request_camera_impulse(0.18, 0.03)
	GameEvents.request_toast("%s // online" % _skill_name())


func _tick_weapon_skill_cooldown(delta: float) -> void:
	if _weapon_skill_cooldown_timer <= 0.0:
		return
	_weapon_skill_cooldown_timer = maxf(0.0, _weapon_skill_cooldown_timer - delta)


func _tick_weapon_pierce(delta: float) -> void:
	if _weapon_pierce_timer <= 0.0:
		return
	_weapon_pierce_timer = maxf(0.0, _weapon_pierce_timer - delta)
	if _weapon_pierce_timer <= 0.0:
		GameEvents.request_toast("%s // offline" % _skill_name())


func _try_next_gen_energy_burst() -> void:
	if weapon_data == null:
		return
	if _weapon_skill_cooldown_timer > 0.0:
		GameEvents.request_toast("%s charging // %.1fs" % [_skill_name(), _weapon_skill_cooldown_timer])
		return
	_weapon_skill_cooldown_timer = maxf(0.0, weapon_data.skill_cooldown)
	var aim_direction := _aim_direction_from(global_position)
	var aim_facing := _aim_facing_for(aim_direction)
	if aim_facing != _facing:
		_facing = aim_facing
		_update_facing_visual()
	var center := global_position + aim_direction * _next_gen_skill_range() + Vector2(0.0, -18.0)
	var targets := _collect_targets_in_radius(center, _next_gen_skill_radius())
	GameEvents.request_vfx(&"skill_next_gen_burst", center, _facing)
	GameEvents.request_camera_impulse(0.22, 0.04)
	if targets.is_empty():
		GameEvents.request_toast("%s // clear" % _skill_name())
		return

	var base_damage := weapon_data.base_damage_rating + (_enemy_kill_count * weapon_data.skill_damage_bonus_per_kill)
	var hit_count := 0
	for target in targets:
		if target == null or not is_instance_valid(target) or not target.has_method("apply_hit"):
			continue
		var burst_attack := AttackData.new()
		burst_attack.damage = max(1, base_damage)
		if target.has_method("is_boss_enemy") and bool(target.is_boss_enemy()):
			burst_attack.damage = max(1, roundi(float(burst_attack.damage) * weapon_data.skill_boss_damage_scale))
		burst_attack.knockback = Vector2(180.0, -80.0)
		burst_attack.hit_stun = 0.12
		burst_attack.hit_stop = 0.02
		burst_attack.screen_shake = 0.18
		burst_attack.vfx_id = &"hit_spark_metal"
		burst_attack.sfx_id = &"sfx_hit_metal_light_01"
		target.apply_hit(burst_attack, self, center, _facing)
		_apply_elemental_on_hit(target, burst_attack, center)
		if not (target.has_method("is_boss_enemy") and bool(target.is_boss_enemy())):
			_apply_control_effect_to_target(target, &"pull", weapon_data.passive_duration, center, 260.0)
		hit_count += 1

	GameEvents.request_toast("%s // burst x%d" % [_skill_name(), hit_count])


func _try_surge_armor_pierce() -> void:
	if weapon_data == null:
		return
	if _weapon_pierce_timer > 0.0:
		GameEvents.request_toast("%s // active" % _skill_name())
		return
	_weapon_pierce_timer = maxf(0.0, weapon_data.skill_duration)
	GameEvents.request_vfx(&"skill_surge_armor_pierce", global_position + Vector2(_facing * 22.0, -22.0), _facing)
	GameEvents.request_toast("%s // online" % _skill_name())


func _apply_next_gen_empowered_hit(target: Node, attack_data: AttackData, hit_position: Vector2) -> void:
	if weapon_data == null or target == null or not target.has_method("apply_hit"):
		return
	var is_boss := target.has_method("is_boss_enemy") and bool(target.is_boss_enemy())
	if is_boss:
		var bonus_scale := maxf(0.0, weapon_data.passive_boss_damage_scale - 1.0)
		if bonus_scale > 0.0:
			var bonus_attack = attack_data.duplicate(true)
			bonus_attack.damage = max(1, roundi(float(attack_data.damage) * bonus_scale))
			bonus_attack.knockback = Vector2.ZERO
			bonus_attack.hit_stun = 0.0
			bonus_attack.hit_stop = 0.0
			bonus_attack.screen_shake = 0.0
			bonus_attack.vfx_id = &""
			bonus_attack.sfx_id = &""
			target.apply_hit(bonus_attack, self, hit_position, _facing)
	else:
		_apply_pull_to_point(hit_position, _next_gen_pull_radius(), _next_gen_pull_duration())

	var is_new_target := _register_attack_target_hit(target)
	_apply_weapon_passive_on_hit(target, attack_data, is_new_target)
	if attack_data.energy_regen > 0:
		_energy = min(_runtime_stats.max_energy, _energy + int(attack_data.energy_regen))
		GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
	GameEvents.request_vfx(&"dash_burst", hit_position, _facing)
	GameEvents.request_camera_impulse(maxf(0.18, attack_data.screen_shake), 0.05)
	_apply_hit_stop(maxf(0.01, attack_data.hit_stop))


func _apply_pull_to_point(center: Vector2, radius: float, duration: float) -> void:
	for target in _collect_targets_in_radius(center, radius):
		if target == null or not is_instance_valid(target):
			continue
		if target.has_method("is_boss_enemy") and bool(target.is_boss_enemy()):
			continue
		_apply_control_effect_to_target(target, &"pull", duration, center, 220.0)


func _collect_targets_in_radius(center: Vector2, radius: float) -> Array[Node]:
	var results: Array[Node] = []
	var seen := {}
	for area in get_tree().get_nodes_in_group("hurtboxes"):
		var hurtbox := area as Area2D
		if hurtbox == null or not is_instance_valid(hurtbox):
			continue
		if hurtbox.global_position.distance_to(center) > radius:
			continue
		if not hurtbox.has_method("get_receiver"):
			continue
		var target: Node = hurtbox.get_receiver()
		if target == null:
			continue
		var key := target.get_instance_id()
		if seen.has(key):
			continue
		seen[key] = true
		results.append(target)
	return results


func _collect_hitscan_targets(start: Vector2, end: Vector2, max_hits: int) -> Array[Dictionary]:
	var remaining := maxi(1, max_hits)
	var exclude: Array[RID] = []
	var results: Array[Dictionary] = []
	var seen := {}
	var current_start := start
	var direction := (end - start).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2(_facing, 0.0)

	while remaining > 0:
		var query := PhysicsRayQueryParameters2D.create(current_start, end, RANGED_HIT_MASK)
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.exclude = exclude
		var hit := get_world_2d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			break

		var area := hit.get("collider") as Area2D
		if area == null or not area.has_method("receive_hit") or not area.has_method("get_receiver"):
			break
		var target: Node = area.call("get_receiver")
		if target == null or target == self:
			break

		var key := target.get_instance_id()
		if not seen.has(key):
			results.append({
				"area": area,
				"target": target,
				"position": hit.get("position", end),
			})
			seen[key] = true
			remaining -= 1
		exclude.append(area.get_rid())
		current_start = Vector2(hit.get("position", current_start)) + direction * 4.0

	return results


func _next_gen_pull_radius() -> float:
	if weapon_data == null:
		return 56.0
	return maxf(24.0, weapon_data.passive_radius)


func _next_gen_pull_duration() -> float:
	if weapon_data == null:
		return 0.5
	return maxf(0.1, weapon_data.passive_duration)


func _next_gen_skill_range() -> float:
	if weapon_data == null:
		return 120.0
	return maxf(48.0, weapon_data.skill_range)


func _next_gen_skill_radius() -> float:
	if weapon_data == null:
		return 84.0
	return maxf(24.0, weapon_data.skill_radius)


func _apply_surge_health_wave(target: Node, _attack_data) -> void:
	if weapon_data == null or target == null or not target.has_method("apply_hit"):
		return
	var max_health := _resolve_target_max_health(target)
	if max_health <= 0:
		return
	var bonus_damage: int = max(1, roundi(float(max_health) * 0.015))
	var wave_attack := AttackData.new()
	wave_attack.damage = bonus_damage
	wave_attack.knockback = Vector2.ZERO
	wave_attack.hit_stun = 0.0
	wave_attack.hit_stop = 0.0
	wave_attack.screen_shake = 0.0
	wave_attack.vfx_id = &"hit_spark_metal"
	wave_attack.sfx_id = &""
	target.apply_hit(wave_attack, self, target.global_position, _facing)


func _apply_elemental_self_modifiers() -> void:
	if weapon_data == null:
		return
	match weapon_data.element_type:
		&"wind":
			_runtime_stats.move_speed *= 1.1
		&"water":
			_runtime_stats.max_health = max(1, roundi(float(_runtime_stats.max_health) * 1.05))
			_health = min(_health, _runtime_stats.max_health)


func _apply_elemental_on_hit(target: Node, attack_data: AttackData, hit_position: Vector2) -> void:
	if weapon_data == null or target == null:
		return
	match weapon_data.element_type:
		&"thunder":
			var is_boss := target.has_method("is_boss_enemy") and bool(target.is_boss_enemy())
			if is_boss:
				_thunder_boss_bonus_stacks += 1
				var bonus_attack := attack_data.duplicate(true)
				bonus_attack.damage = max(1, roundi(float(weapon_data.base_damage_rating) * 0.01 * float(_thunder_boss_bonus_stacks)))
				target.apply_hit(bonus_attack, self, hit_position, _facing)
			else:
				_apply_control_effect_to_target(target, &"thunder_root", 0.05, hit_position)
		_:
			return


func _apply_control_effect_to_target(target: Node, effect_id: StringName, duration: float, world_position: Vector2, strength: float = 0.0) -> void:
	if target == null or not is_instance_valid(target):
		return
	if target.has_method("apply_control_effect"):
		target.apply_control_effect(effect_id, duration, world_position, strength)
		return
	if effect_id == &"pull" and target is CharacterBody2D:
		var body_target := target as CharacterBody2D
		var direction := world_position - body_target.global_position
		if direction.length_squared() > 1.0:
			body_target.velocity = direction.normalized() * maxf(180.0, strength)


func _restore_equipped_weapon_passive_state() -> void:
	var slot := _equipped_weapon_slot_index()
	if slot < 0:
		_ranged_shot_counter = 0
		_next_shot_empowered = false
		return
	_ranged_shot_counter = _weapon_slot_shot_counter[slot]
	_next_shot_empowered = _weapon_slot_next_empowered[slot]


func _save_equipped_weapon_passive_state() -> void:
	var slot := _equipped_weapon_slot_index()
	if slot < 0:
		return
	_weapon_slot_shot_counter[slot] = _ranged_shot_counter
	_weapon_slot_next_empowered[slot] = _next_shot_empowered


func _try_reverse_charge_katana_skill() -> void:
	if weapon_data == null:
		return
	if _attack_locked or _ultimate_active:
		return
	var skill_attack := _skill_attack()
	if skill_attack == null:
		GameEvents.request_toast("%s // offline" % _skill_name())
		return

	var aim_direction := _aim_direction_from(global_position)
	var aim_facing := _aim_facing_for(aim_direction)
	if aim_facing != _facing:
		_facing = aim_facing
		_update_facing_visual()

	var blink_distance := maxf(96.0, weapon_data.skill_range if weapon_data.skill_range > 0.0 else 220.0)
	var target_position := global_position + aim_direction * blink_distance
	var origin_position := global_position
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target_position, 1)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [get_rid()]
	var hit := space_state.intersect_ray(query)
	if not hit.is_empty():
		var collision_point: Vector2 = hit.get("position", target_position)
		target_position = collision_point - aim_direction * 18.0

	_attack_locked = true
	_last_attack_hit_targets.clear()
	var attack: AttackData = skill_attack.duplicate(true)
	attack.damage = max(1, roundi(float(attack.damage) * _item_damage_mult * _weapon_damage_scale()))
	global_position = target_position
	velocity = Vector2.ZERO
	_restore_hitbox()
	hitbox.activate(attack, self, _facing)
	animation_controller.play_action(&"skill")
	GameEvents.request_vfx(&"skill_katana_flash", origin_position + Vector2(0.0, -28.0), _facing)
	GameEvents.request_vfx(&"skill_katana_flash", global_position + Vector2(0.0, -28.0), _facing)
	GameEvents.request_camera_impulse(maxf(0.28, attack.screen_shake), 0.05)
	await get_tree().create_timer(maxf(0.08, attack.active_time + 0.06)).timeout
	# dash 可能在 await 期间被触发，此时不要覆盖 dash 状态
	if _dash_timer > 0.0:
		return
	_attack_locked = false
	animation_controller.clear_action()
	_update_movement_animation()


func _resolve_target_max_health(target: Node) -> int:
	if target == null:
		return 0
	if target.has_method("max_health_value"):
		return int(target.max_health_value())
	return 0


func _tick_bleed_effects(delta: float) -> void:
	if _bleed_targets.is_empty():
		return

	var expired_keys: Array = []
	for key in _bleed_targets.keys():
		var entry: Dictionary = _bleed_targets[key]
		var target: Node = entry.get("target")
		if target == null or not is_instance_valid(target) or not target.is_inside_tree():
			expired_keys.append(key)
			continue

		entry["time_left"] = maxf(0.0, float(entry.get("time_left", 0.0)) - delta)
		entry["tick_timer"] = maxf(0.0, float(entry.get("tick_timer", 0.0)) - delta)
		if float(entry["tick_timer"]) <= 0.0:
			var bleed_damage: int = maxi(
				1,
				roundi(int(entry.get("base_damage", 1)) * weapon_data.passive_bleed_damage_scale)
			) * maxi(1, int(entry.get("stacks", 1)))
			var bleed_attack := AttackData.new()
			bleed_attack.damage = bleed_damage
			bleed_attack.knockback = Vector2.ZERO
			bleed_attack.hit_stun = 0.0
			bleed_attack.hit_stop = 0.0
			bleed_attack.screen_shake = 0.0
			bleed_attack.vfx_id = &"hit_spark_metal"
			bleed_attack.sfx_id = &""
			target.apply_hit(bleed_attack, self, global_position, _facing)
			entry["tick_timer"] = 1.0
		if float(entry["time_left"]) <= 0.0:
			expired_keys.append(key)
		else:
			_bleed_targets[key] = entry

	for key in expired_keys:
		_bleed_targets.erase(key)
