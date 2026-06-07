class_name EnemyController
extends CharacterBody2D

enum EnemyState { PATROL, ALERT, CHASE, STRAFE, WINDUP, RECOVERY, HURT, LEASH }

const DEFAULT_STATS = preload("res://resources/characters/drone_stats.tres")
const DEFAULT_ATTACK = preload("res://resources/attacks/enemy_metal_swipe.tres")

@export var enemy_id: StringName = &"enemy"
@export var stats: CharacterStats = DEFAULT_STATS
@export var attack_data: AttackData = DEFAULT_ATTACK
@export var heavy_attack_data: AttackData
@export var elite_tier: StringName = &"normal"
@export var behavior_type: StringName = &"chaser"
@export var aggro_range: float = 190.0
@export var lose_aggro_range: float = 320.0
@export var vertical_aggro_range: float = 96.0
@export var attack_range: float = 42.0
@export var preferred_range: float = 68.0
@export var attack_interval: float = 0.9
@export var attack_windup: float = 0.18
@export var attack_recovery: float = 0.28
@export var special_attack_every: int = 0
@export var patrol_width: float = 80.0
@export var patrol_speed_scale: float = 0.45
@export var chase_speed_scale: float = 1.0
@export var strafe_duration: float = 0.55
@export var hurt_stun_duration: float = 0.16
@export var leash_return_speed_scale: float = 0.75
@export var enrage_health_ratio: float = 0.35
@export var enrage_speed_scale: float = 1.2
@export var enrage_attack_interval_scale: float = 0.75
@export var drop_item_scene: PackedScene

@onready var visual_root: Node2D = $VisualRoot
@onready var body: Polygon2D = $VisualRoot/Body
@onready var eye: Polygon2D = $VisualRoot/Eye
@onready var hitbox: Hitbox = $FacingPivot/Hitbox
@onready var facing_pivot: Node2D = $FacingPivot
@onready var debug_label: Label = $DebugLabel

var _runtime_stats: CharacterStats
var _health: int = 1
var _spawn_position: Vector2 = Vector2.ZERO
var _facing: int = -1
var _state: EnemyState = EnemyState.PATROL
var _state_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _attack_count: int = 0
var _current_attack: AttackData
var _dead: bool = false
var _enraged: bool = false
var _player: Node2D
var _rooted_timer: float = 0.0
var _pull_timer: float = 0.0
var _pull_anchor: Vector2 = Vector2.ZERO
var _pull_speed: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses" if elite_tier == &"boss" else "non_boss_enemies")
	_runtime_stats = stats.runtime_copy()
	_health = _runtime_stats.max_health
	_spawn_position = global_position
	_player = get_tree().get_first_node_in_group("player") as Node2D
	_update_facing_visual()


func _physics_process(delta: float) -> void:
	if _dead:
		return

	_attack_cooldown_timer = maxf(0.0, _attack_cooldown_timer - delta)
	_state_timer = maxf(0.0, _state_timer - delta)
	_rooted_timer = maxf(0.0, _rooted_timer - delta)
	_pull_timer = maxf(0.0, _pull_timer - delta)
	if not is_on_floor():
		velocity.y += _gravity() * delta

	if _pull_timer > 0.0:
		_process_pull(delta)
		move_and_slide()
		_update_debug_label()
		return

	if _rooted_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * 3.0 * delta)
		move_and_slide()
		_update_debug_label()
		return

	_check_enrage()
	_update_state(delta)
	move_and_slide()
	_update_debug_label()


func apply_hit(incoming_attack, source: Node2D, _hit_position: Vector2, facing: int) -> void:
	if _dead:
		return

	_health = max(0, _health - int(incoming_attack.damage))
	_player = source if source != null and source.is_in_group("player") else _player
	var knock_direction: int = facing
	if source != null:
		knock_direction = 1 if global_position.x >= source.global_position.x else -1
	velocity.x = incoming_attack.knockback.x * knock_direction
	velocity.y = incoming_attack.knockback.y
	_flash()

	if _health <= 0:
		_die()
		return
	_set_state(EnemyState.HURT, hurt_stun_duration)


func health_ratio() -> float:
	if _runtime_stats == null or _runtime_stats.max_health <= 0:
		return 0.0
	return clampf(float(_health) / float(_runtime_stats.max_health), 0.0, 1.0)


func max_health_value() -> int:
	if _runtime_stats == null:
		return 0
	return int(_runtime_stats.max_health)


func is_boss_enemy() -> bool:
	return elite_tier == &"boss"


func apply_control_effect(effect_id: StringName, duration: float, world_position: Vector2 = Vector2.ZERO, strength: float = 0.0) -> void:
	if _dead:
		return
	if elite_tier == &"boss" and effect_id != &"thunder_mark":
		return

	match effect_id:
		&"thunder_root":
			_rooted_timer = maxf(_rooted_timer, duration)
			_set_state(EnemyState.HURT, maxf(_state_timer, minf(duration, hurt_stun_duration)))
		&"pull":
			_pull_anchor = world_position
			_pull_speed = maxf(180.0, strength)
			_pull_timer = maxf(_pull_timer, duration)
			_rooted_timer = maxf(_rooted_timer, duration)
			_set_state(EnemyState.HURT, maxf(_state_timer, minf(duration, hurt_stun_duration)))


func _update_state(delta: float) -> void:
	match _state:
		EnemyState.PATROL:
			_patrol(delta)
			if _can_see_player():
				_set_state(EnemyState.ALERT, _alert_time())
		EnemyState.ALERT:
			velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * delta)
			_face_player()
			if _state_timer <= 0.0:
				_set_state(EnemyState.CHASE)
		EnemyState.CHASE:
			_chase(delta)
		EnemyState.STRAFE:
			_strafe(delta)
		EnemyState.WINDUP:
			velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * delta)
			_face_player()
			if _state_timer <= 0.0:
				_execute_attack()
		EnemyState.RECOVERY:
			velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * delta)
			if _state_timer <= 0.0:
				_set_state(EnemyState.CHASE if _can_see_player() else EnemyState.LEASH)
		EnemyState.HURT:
			velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * delta)
			if _state_timer <= 0.0:
				_set_state(EnemyState.CHASE if _can_see_player() else EnemyState.LEASH)
		EnemyState.LEASH:
			_return_to_spawn(delta)


func _chase(delta: float) -> void:
	if not _player_alive() or _distance_to_spawn() > lose_aggro_range:
		_set_state(EnemyState.LEASH)
		return
	var offset := _player.global_position - global_position
	var horizontal_distance := absf(offset.x)
	_face_player()
	if horizontal_distance <= attack_range and _attack_cooldown_timer <= 0.0:
		_start_attack()
		return
	if behavior_type == &"skirmisher" and horizontal_distance < preferred_range:
		_set_state(EnemyState.STRAFE, strafe_duration)
		return
	var speed := _runtime_stats.move_speed * chase_speed_scale * _enrage_move_scale()
	velocity.x = move_toward(velocity.x, _facing * speed, _runtime_stats.acceleration * delta)


func _strafe(delta: float) -> void:
	if not _player_alive():
		_set_state(EnemyState.LEASH)
		return
	_face_player()
	var direction := -_facing
	var speed := _runtime_stats.move_speed * 0.85 * _enrage_move_scale()
	velocity.x = move_toward(velocity.x, direction * speed, _runtime_stats.acceleration * delta)
	if _state_timer <= 0.0:
		_set_state(EnemyState.CHASE)


func _patrol(delta: float) -> void:
	if absf(global_position.x - _spawn_position.x) > patrol_width:
		_facing *= -1
		_update_facing_visual()
	var speed := _runtime_stats.move_speed * patrol_speed_scale
	velocity.x = move_toward(velocity.x, _facing * speed, _runtime_stats.acceleration * delta)


func _process_pull(delta: float) -> void:
	var offset := _pull_anchor - global_position
	if offset.length_squared() <= 36.0:
		velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * 4.0 * delta)
		return
	var pull_velocity := offset.normalized() * _pull_speed
	velocity.x = move_toward(velocity.x, pull_velocity.x, _runtime_stats.acceleration * 3.0 * delta)
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, pull_velocity.y, _gravity() * 0.2 * delta)


func _return_to_spawn(delta: float) -> void:
	var offset := _spawn_position.x - global_position.x
	if absf(offset) <= 6.0:
		velocity.x = move_toward(velocity.x, 0.0, _runtime_stats.friction * delta)
		_set_state(EnemyState.PATROL)
		return
	_facing = 1 if offset > 0.0 else -1
	_update_facing_visual()
	var speed := _runtime_stats.move_speed * leash_return_speed_scale
	velocity.x = move_toward(velocity.x, _facing * speed, _runtime_stats.acceleration * delta)


func _start_attack() -> void:
	_current_attack = _select_attack()
	_attack_cooldown_timer = _current_attack_interval()
	_set_state(EnemyState.WINDUP, attack_windup)
	GameEvents.request_vfx(&"dash_burst", global_position + Vector2(_facing * 18.0, -24.0), _facing)


func _execute_attack() -> void:
	if _current_attack == null:
		_current_attack = attack_data
	hitbox.activate(_current_attack.duplicate(true), self, _facing)
	velocity.x = _facing * _current_attack.lunge
	_set_state(EnemyState.RECOVERY, attack_recovery + _current_attack.active_time)


func _select_attack() -> AttackData:
	_attack_count += 1
	if heavy_attack_data != null and special_attack_every > 0 and _attack_count % special_attack_every == 0:
		return heavy_attack_data
	if heavy_attack_data != null and _enraged and elite_tier != &"normal":
		return heavy_attack_data
	return attack_data


func _can_see_player() -> bool:
	if not _player_alive():
		return false
	var offset := _player.global_position - global_position
	return absf(offset.x) <= aggro_range and absf(offset.y) <= vertical_aggro_range


func _player_alive() -> bool:
	return _player != null and _player.has_method("is_alive") and _player.is_alive()


func _face_player() -> void:
	if _player == null:
		return
	var offset_x := _player.global_position.x - global_position.x
	if absf(offset_x) > 1.0:
		_facing = 1 if offset_x > 0.0 else -1
		_update_facing_visual()


func _set_state(next_state: EnemyState, duration: float = 0.0) -> void:
	_state = next_state
	_state_timer = duration


func _check_enrage() -> void:
	if _enraged or elite_tier == &"normal" or health_ratio() > enrage_health_ratio:
		return
	_enraged = true
	_flash()
	GameEvents.request_toast("%s // overclock" % String(enemy_id))
	GameEvents.request_camera_impulse(0.45, 0.08)


func _current_attack_interval() -> float:
	return maxf(0.12, attack_interval * (enrage_attack_interval_scale if _enraged else 1.0))


func _enrage_move_scale() -> float:
	return enrage_speed_scale if _enraged else 1.0


func _alert_time() -> float:
	if behavior_type == &"ambusher":
		return 0.05
	if elite_tier == &"boss":
		return 0.3
	return 0.16


func _distance_to_spawn() -> float:
	return global_position.distance_to(_spawn_position)


func _die() -> void:
	_dead = true
	hitbox.deactivate()
	_disarm_hurtbox()
	GameEvents.report_enemy_defeated(enemy_id)
	GameEvents.request_vfx(&"hit_spark_metal", global_position + Vector2(0.0, -20.0), _facing)
	GameEvents.request_camera_impulse(0.9, 0.1)
	if drop_item_scene != null:
		var drop: Node2D = drop_item_scene.instantiate()
		drop.global_position = global_position + Vector2(0.0, -24.0)
		get_parent().add_child(drop)
	call_deferred("queue_free")

func _disarm_hurtbox() -> void:
	var hurtbox_node: Area2D = get_node_or_null("Hurtbox") as Area2D
	if hurtbox_node == null:
		return
	hurtbox_node.monitoring = false
	hurtbox_node.monitorable = false
	var hurtbox_shape: CollisionShape2D = hurtbox_node.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if hurtbox_shape != null:
		hurtbox_shape.set_deferred("disabled", true)

func _flash() -> void:
	body.modulate = Color(1.0, 0.27, 0.18, 1.0)
	eye.modulate = Color.WHITE
	var tween: Tween = create_tween()
	tween.tween_property(body, "modulate", Color.WHITE, 0.12)
	tween.parallel().tween_property(eye, "modulate", Color(1.0, 0.08, 0.12, 1.0), 0.12)


func _update_facing_visual() -> void:
	facing_pivot.scale.x = _facing
	visual_root.scale.x = _facing


func _update_debug_label() -> void:
	debug_label.text = "%s %d %s" % [String(enemy_id), _health, EnemyState.keys()[_state]]


func _gravity() -> float:
	return ProjectSettings.get_setting("physics/2d/default_gravity") * _runtime_stats.gravity_scale
