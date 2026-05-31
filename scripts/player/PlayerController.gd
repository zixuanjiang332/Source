class_name PlayerController
extends CharacterBody2D

const DEFAULT_STATS = preload("res://resources/characters/player_stats.tres")
const DEFAULT_WEAPON = preload("res://resources/weapons/initial_dagger.tres")
const ATTACK_CHAIN = [
	preload("res://resources/attacks/dagger_cut_1.tres"),
	preload("res://resources/attacks/dagger_cut_2.tres"),
	preload("res://resources/attacks/dagger_cut_3.tres"),
]
const SKILL_ATTACK = preload("res://resources/attacks/dagger_flash_step.tres")
const VISUAL_SCALE := 0.70

@export var stats = DEFAULT_STATS
@export var weapon_data = DEFAULT_WEAPON

@onready var animated_sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite
@onready var body: Polygon2D = $VisualRoot/FallbackRoot/Body
@onready var visor: Polygon2D = $VisualRoot/FallbackRoot/Visor
@onready var hitbox = $FacingPivot/Hitbox
@onready var hurtbox = $Hurtbox
@onready var facing_pivot: Node2D = $FacingPivot
@onready var debug_label: Label = $DebugLabel
@onready var animation_controller: PlayerAnimationController = $AnimationController

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

func _ready() -> void:
	add_to_group("player")
	_runtime_stats = stats.runtime_copy()
	_health = _runtime_stats.max_health
	_energy = _runtime_stats.max_energy
	GameEvents.report_player_health(_health, _runtime_stats.max_health)
	GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
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

	if Input.is_action_just_pressed("skill"):
		_try_skill()

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


func is_alive() -> bool:
	return not _dead


func _tick_timers(delta: float) -> void:
	_dash_timer = max(0.0, _dash_timer - delta)
	_dash_cooldown_timer = max(0.0, _dash_cooldown_timer - delta)
	_invulnerable_timer = max(0.0, _invulnerable_timer - delta)
	_combo_reset_timer = max(0.0, _combo_reset_timer - delta)
	if _combo_reset_timer <= 0.0 and _last_reported_combo != 0:
		_combo_index = 0
		_report_combo(0)


func _start_dash() -> void:
	_dash_timer = _runtime_stats.dash_duration
	_dash_cooldown_timer = _runtime_stats.dash_cooldown
	_invulnerable_timer = max(_invulnerable_timer, _runtime_stats.dash_duration)
	animation_controller.play_state(&"dash")
	GameEvents.request_vfx(&"dash_burst", global_position + Vector2(0.0, -28.0), _facing)
	GameEvents.request_camera_impulse(0.35, 0.04)


func _try_attack() -> void:
	if _attack_locked:
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

	if _attack_locked:
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
	var attack = template.duplicate(true)
	attack.damage = max(1, roundi(float(attack.damage) * _damage_multiplier))
	velocity.x += _facing * attack.lunge
	_update_facing_visual()
	animation_controller.play_action(_resolve_attack_animation(attack))
	hitbox.activate(attack, self, _facing)

	await get_tree().create_timer(attack.cooldown).timeout
	_attack_locked = false
	animation_controller.clear_action()
	_update_movement_animation()


func _on_hit_landed(_target: Node, attack_data) -> void:
	var energy_gain := 9
	if attack_data.attack_id == &"dagger_flash_step":
		energy_gain = 3
	_energy = min(_runtime_stats.max_energy, _energy + energy_gain)
	GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
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
	var state := "AIR"
	if is_on_floor():
		state = "READY"
	if _dash_timer > 0.0:
		state = "DASH"
	if _attack_locked:
		state = "STRIKE"
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


func _report_weapon() -> void:
	var weapon_name := "Dagger"
	var skill_name := _skill_name()
	var skill_attack: Resource = _skill_attack()
	var skill_cost := 0
	if skill_attack != null:
		skill_cost = skill_attack.energy_cost
	if weapon_data != null and weapon_data.get("display_name") != null:
		weapon_name = weapon_data.display_name
	GameEvents.report_player_weapon(weapon_name, skill_name, skill_cost)


func _report_combo(combo_step: int) -> void:
	if _last_reported_combo == combo_step:
		return
	_last_reported_combo = combo_step
	GameEvents.report_player_combo(combo_step, _attack_chain().size())


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
