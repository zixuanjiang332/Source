class_name Projectile
extends Area2D

## 子弹投射物
## 由远程武器发射，飞行一段距离或直到命中目标

signal hit_target(target: Node, attack_data: AttackData, hit_position: Vector2, was_empowered: bool)
signal expired

var speed: float = 800.0
var lifetime: float = 1.5
var pierce_count: int = 1
var max_bounces: int = 0
var attack_data: AttackData
var source: Node2D
var facing: int = 1
var direction: Vector2 = Vector2.RIGHT
var visual_size: Vector2 = Vector2(12.0, 6.0)
var empowered: bool = false

var _velocity: Vector2 = Vector2.ZERO
var _targets_hit: Dictionary = {}
var _remaining_bounces: int = 0
var _alive: bool = false
var _life_remaining: float = 0.0

@onready var visual_rect: ColorRect = $Visual
@onready var visual_sprite: Sprite2D = $VisualSprite

func set_projectile_color(color: Color) -> void:
	var visual = get_node_or_null("Visual") as ColorRect
	if visual != null:
		visual.color = color


func configure_visual(size: Vector2, color: Color, is_empowered: bool = false, texture: Texture2D = null) -> void:
	visual_size = Vector2(maxf(2.0, size.x), maxf(2.0, size.y))
	empowered = is_empowered
	if visual_rect != null:
		visual_rect.visible = texture == null
		visual_rect.color = color.lightened(0.25) if empowered else color
		visual_rect.offset_left = -visual_size.x * 0.5
		visual_rect.offset_top = -visual_size.y * 0.5
		visual_rect.offset_right = visual_size.x * 0.5
		visual_rect.offset_bottom = visual_size.y * 0.5
	if visual_sprite != null:
		visual_sprite.visible = texture != null
		visual_sprite.texture = texture
		visual_sprite.modulate = color.lightened(0.25) if empowered else color
		if texture != null:
			visual_sprite.scale = Vector2(
				visual_size.x / maxf(1.0, texture.get_width()),
				visual_size.y / maxf(1.0, texture.get_height())
			)
	var shape_node = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node != null:
		var rect := shape_node.shape as RectangleShape2D
		if rect != null:
			shape_node.shape = rect.duplicate()
			rect = shape_node.shape as RectangleShape2D
			rect.size = visual_size


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	# 碰撞层：子弹（Layer 32）
	collision_layer = 32
	collision_mask = 1 | 4  # 检测 World (Layer 1) + Hurtbox (Layer 4)
	monitoring = true
	monitorable = true

func fire(next_attack_data: AttackData, next_source: Node2D, next_direction: Vector2, next_facing: int, next_speed: float = 800.0, next_lifetime: float = 1.5, next_pierce: int = 1, next_bounces: int = 0) -> void:
	attack_data = next_attack_data
	source = next_source
	direction = next_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT if next_facing >= 0 else Vector2.LEFT
	facing = signi(next_facing)
	speed = next_speed
	lifetime = next_lifetime
	pierce_count = next_pierce
	pierce_count = maxi(1, pierce_count)
	max_bounces = next_bounces
	_remaining_bounces = next_bounces

	_velocity = direction * speed
	rotation = direction.angle()
	_targets_hit.clear()
	_alive = true
	_life_remaining = lifetime

func _physics_process(delta: float) -> void:
	if not _alive:
		return
	position += _velocity * delta
	_life_remaining -= delta
	if _life_remaining <= 0.0:
		_expire()

func _on_area_entered(area: Area2D) -> void:
	if not _alive or attack_data == null:
		return

	if not area.has_method("receive_hit") or not area.has_method("get_receiver"):
		return

	var target: Node = area.call("get_receiver")
	if target == null or target == source:
		return

	var key: int = area.get_instance_id()
	if _targets_hit.has(key):
		return

	_targets_hit[key] = true
	area.call("receive_hit", attack_data, source, global_position, facing)
	hit_target.emit(target, attack_data, global_position, empowered)

	# VFX/SFX
	GameEvents.request_vfx(attack_data.vfx_id, global_position, facing)
	GameEvents.request_sfx(attack_data.sfx_id, global_position)
	GameEvents.request_camera_impulse(attack_data.screen_shake, 0.04)

	# 穿透逻辑
	if _targets_hit.size() >= pierce_count:
		_expire()

func _on_body_entered(body: Node) -> void:
	# Walls / obstacles: bounce if remaining bounces, otherwise expire
	if body == source:
		return
	if body.is_in_group("world") or body.is_in_group("obstacles"):
		if _remaining_bounces > 0:
			_try_bounce(body)
		else:
			if attack_data != null:
				GameEvents.request_vfx(attack_data.vfx_id, global_position, facing)
			_expire()

func _try_bounce(wall_body: Node) -> void:
	_remaining_bounces -= 1

	# Raycast to find wall normal — shoot a short ray backward from the projectile
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, global_position - _velocity.normalized() * 16.0, collision_mask, [self])
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var result := space_state.intersect_ray(query)

	var normal := Vector2.ZERO
	if not result.is_empty():
		normal = result.normal
	else:
		# Fallback: reflect based on velocity direction and wall body position
		if wall_body is CollisionObject2D:
			var wall_pos := (wall_body as CollisionObject2D).global_position
			var to_wall := (wall_pos - global_position).normalized()
			if absf(to_wall.x) > absf(to_wall.y):
				normal = Vector2(signf(-to_wall.x), 0.0)
			else:
				normal = Vector2(0.0, signf(-to_wall.y))
		else:
			# Last resort: reflect velocity
			normal = -_velocity.normalized()

	# Reflect velocity across the surface normal
	_velocity = _velocity.bounce(normal)
	direction = _velocity.normalized()
	rotation = _velocity.angle()

	# Reset lifetime a bit so the bounce doesn't waste travel distance
	_life_remaining = maxf(_life_remaining, 0.3)

	if attack_data != null:
		GameEvents.request_vfx(attack_data.vfx_id, global_position, facing)


func _expire() -> void:
	if not _alive:
		return
	_alive = false
	monitoring = false
	monitorable = false
	expired.emit()
	# 延迟一帧再删除，避免当帧问题
	if is_inside_tree() and get_tree() != null:
		await get_tree().process_frame
	if is_inside_tree():
		queue_free()

func signi(value: int) -> int:
	if value < 0:
		return -1
	if value > 0:
		return 1
	return 0