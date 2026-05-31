class_name EnemyController
extends CharacterBody2D

const DEFAULT_STATS = preload("res://resources/characters/drone_stats.tres")
const DEFAULT_ATTACK = preload("res://resources/attacks/enemy_metal_swipe.tres")

@export var enemy_id: StringName = &"enemy"
@export var stats = DEFAULT_STATS
@export var attack_data = DEFAULT_ATTACK
@export var aggro_range := 190.0
@export var attack_range := 42.0
@export var attack_interval := 0.9
@export var patrol_width := 80.0
@export var drop_item_scene: PackedScene

@onready var body: Polygon2D = $VisualRoot/Body
@onready var eye: Polygon2D = $VisualRoot/Eye
@onready var hitbox = $FacingPivot/Hitbox
@onready var facing_pivot: Node2D = $FacingPivot
@onready var debug_label: Label = $DebugLabel

var _runtime_stats
var _health := 1
var _spawn_x := 0.0
var _facing := -1
var _attack_timer := 0.0
var _dead := false
var _player: Node2D

func _ready() -> void:
	add_to_group("enemies")
	_runtime_stats = stats.runtime_copy()
	_health = _runtime_stats.max_health
	_spawn_x = global_position.x
	_player = get_tree().get_first_node_in_group("player") as Node2D
	_update_facing_visual()


func _physics_process(delta: float) -> void:
	if _dead:
		return

	_attack_timer = max(0.0, _attack_timer - delta)
	if not is_on_floor():
		velocity.y += _gravity() * delta

	if _player != null and _player.has_method("is_alive") and _player.is_alive():
		_chase_or_attack(delta)
	else:
		_patrol(delta)

	move_and_slide()
	_update_debug_label()


func apply_hit(attack_data, source: Node2D, _hit_position: Vector2, facing: int) -> void:
	if _dead:
		return

	_health = max(0, _health - attack_data.damage)
	var knock_direction := facing
	if source != null:
		knock_direction = 1 if global_position.x >= source.global_position.x else -1
	velocity.x = attack_data.knockback.x * knock_direction
	velocity.y = attack_data.knockback.y
	_flash()

	if _health <= 0:
		_die()


func _chase_or_attack(delta: float) -> void:
	var distance := _player.global_position - global_position
	var horizontal_distance := absf(distance.x)

	if horizontal_distance <= aggro_range:
		_facing = 1 if distance.x > 0.0 else -1
		_update_facing_visual()

		if horizontal_distance <= attack_range and _attack_timer <= 0.0:
			_attack()
		else:
			velocity.x = move_toward(velocity.x, _facing * _runtime_stats.move_speed, _runtime_stats.acceleration * delta)
	else:
		_patrol(delta)


func _patrol(delta: float) -> void:
	if absf(global_position.x - _spawn_x) > patrol_width:
		_facing *= -1
		_update_facing_visual()
	velocity.x = move_toward(velocity.x, _facing * _runtime_stats.move_speed * 0.45, _runtime_stats.acceleration * delta)


func _attack() -> void:
	_attack_timer = attack_interval
	var attack = attack_data.duplicate(true)
	hitbox.activate(attack, self, _facing)
	velocity.x = _facing * attack.lunge


func _die() -> void:
	_dead = true
	hitbox.deactivate()
	GameEvents.report_enemy_defeated(enemy_id)
	GameEvents.request_vfx(&"hit_spark_metal", global_position + Vector2(0.0, -20.0), _facing)
	GameEvents.request_camera_impulse(0.9, 0.1)

	if drop_item_scene != null:
		var drop := drop_item_scene.instantiate()
		drop.global_position = global_position + Vector2(0.0, -24.0)
		get_parent().add_child(drop)

	queue_free()


func _flash() -> void:
	body.modulate = Color(1.0, 0.27, 0.18, 1.0)
	eye.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(body, "modulate", Color.WHITE, 0.12)
	tween.parallel().tween_property(eye, "modulate", Color(1.0, 0.08, 0.12, 1.0), 0.12)


func _update_facing_visual() -> void:
	facing_pivot.scale.x = _facing
	$VisualRoot.scale.x = _facing


func _update_debug_label() -> void:
	debug_label.text = "%s %d" % [String(enemy_id), _health]


func _gravity() -> float:
	return ProjectSettings.get_setting("physics/2d/default_gravity") * _runtime_stats.gravity_scale
