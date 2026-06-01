class_name AttackData
extends Resource

@export var attack_id: StringName = &"attack"
@export var display_name := "Attack"
@export var animation_id: StringName = &""
@export var damage := 10
@export var energy_cost := 0
@export var knockback := Vector2(160.0, -70.0)
@export var lunge := 0.0
@export var active_time := 0.08
@export var cooldown := 0.18
@export var hit_stun := 0.14
@export var hit_stop := 0.035
@export var screen_shake := 0.55
@export var vfx_id: StringName = &"hit_spark_metal"
@export var sfx_id: StringName = &"sfx_hit_metal_light_01"

func resolved_animation_id() -> StringName:
	if animation_id != &"":
		return animation_id
	return attack_id
