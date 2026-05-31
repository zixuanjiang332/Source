class_name PlayerController
extends CharacterBody2D

const DEFAULT_STATS = preload("res://resources/characters/player_stats.tres")
const ATTACK_CHAIN = [
	preload("res://resources/attacks/player_slash_1.tres"),
	preload("res://resources/attacks/player_slash_2.tres"),
	preload("res://resources/attacks/player_slash_3.tres"),
]
const SKILL_ATTACK = preload("res://resources/attacks/player_energy_cleave.tres")

@export var stats = DEFAULT_STATS

@onready var body: Polygon2D = $VisualRoot/Body
@onready var visor: Polygon2D = $VisualRoot/Visor
@onready var hitbox = $FacingPivot/Hitbox
@onready var hurtbox = $Hurtbox
@onready var facing_pivot: Node2D = $FacingPivot
@onready var debug_label: Label = $DebugLabel

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

func _ready() -> void:
	add_to_group("player")
	_runtime_stats = stats.runtime_copy()
	_health = _runtime_stats.max_health
	_energy = _runtime_stats.max_energy
	GameEvents.report_player_health(_health, _runtime_stats.max_health)
	GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
	hitbox.hit_landed.connect(_on_hit_landed)
	_update_facing_visual()


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
	if _combo_reset_timer <= 0.0:
		_combo_index = 0


func _start_dash() -> void:
	_dash_timer = _runtime_stats.dash_duration
	_dash_cooldown_timer = _runtime_stats.dash_cooldown
	_invulnerable_timer = max(_invulnerable_timer, _runtime_stats.dash_duration)
	GameEvents.request_vfx(&"dash_burst", global_position + Vector2(0.0, -28.0), _facing)
	GameEvents.request_camera_impulse(0.35, 0.04)


func _try_attack() -> void:
	if _attack_locked:
		return

	var template: Resource = ATTACK_CHAIN[_combo_index]
	_combo_index = (_combo_index + 1) % ATTACK_CHAIN.size()
	_combo_reset_timer = 0.55
	_start_attack(template)


func _try_skill() -> void:
	if _attack_locked or _energy < SKILL_ATTACK.energy_cost:
		return

	_energy -= SKILL_ATTACK.energy_cost
	GameEvents.report_player_energy(_energy, _runtime_stats.max_energy)
	_start_attack(SKILL_ATTACK)


func _start_attack(template) -> void:
	_attack_locked = true
	var attack = template.duplicate(true)
	attack.damage = max(1, roundi(float(attack.damage) * _damage_multiplier))
	velocity.x += _facing * attack.lunge
	_update_facing_visual()
	hitbox.activate(attack, self, _facing)

	await get_tree().create_timer(attack.cooldown).timeout
	_attack_locked = false


func _on_hit_landed(_target: Node, attack_data) -> void:
	_energy = min(_runtime_stats.max_energy, _energy + 8)
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
	$VisualRoot.scale.x = _facing


func _update_debug_label() -> void:
	var state := "AIR"
	if is_on_floor():
		state = "READY"
	if _dash_timer > 0.0:
		state = "DASH"
	if _attack_locked:
		state = "STRIKE"
	debug_label.text = state


func _flash(color: Color) -> void:
	body.modulate = color
	visor.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(body, "modulate", Color.WHITE, 0.1)
	tween.parallel().tween_property(visor, "modulate", Color(0.35, 1.0, 1.0, 1.0), 0.1)


func _die() -> void:
	_dead = true
	hitbox.deactivate()
	body.modulate = Color(0.22, 0.22, 0.28, 1.0)
	debug_label.text = "OFFLINE - R"
	GameEvents.request_camera_impulse(1.2, 0.18)


func _gravity() -> float:
	return ProjectSettings.get_setting("physics/2d/default_gravity") * _runtime_stats.gravity_scale
