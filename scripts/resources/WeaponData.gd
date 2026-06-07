class_name WeaponData
extends Resource

@export var weapon_id: StringName = &"weapon"
@export var display_name: String = "Weapon"
@export_multiline var description: String = ""
@export var weapon_type: StringName = &"melee"
@export var element_type: StringName = &"none"
@export var world_texture: Texture2D
@export var hud_icon: Texture2D
@export var icon_texture: Texture2D
@export var base_damage_rating: int = 10
@export var attack_speed_rating: int = 10
@export var passive_summary: String = ""
@export var equip_move_speed_scale: float = 1.0
@export var equip_max_health_scale: float = 1.0
@export var attack_damage_scale: float = 1.0
@export var attack_speed_scale: float = 1.0
@export var ammo_capacity: int = 0
@export var attack_mode: StringName = &"melee"
@export var trigger_mode: StringName = &"auto"
@export var fire_pattern: StringName = &"single"
@export var ranged_range: float = 520.0
@export var ranged_pierce_count: int = 1
@export var magazine_size: int = 0
@export var reload_time: float = 0.0
@export var burst_count: int = 1
@export var burst_interval: float = 0.06
@export var pellet_count: int = 1
@export var spread_angle_degrees: float = 0.0
@export var charge_time: float = 0.0
@export var charge_damage_scale: float = 1.0
@export var recoil_impulse: float = 0.0
@export var aim_move_speed_scale: float = 1.0
@export var projectile_speed: float = 800.0
@export var projectile_lifetime: float = 1.5
@export var projectile_size: Vector2 = Vector2(12.0, 6.0)
@export var projectile_texture: Texture2D
@export var projectile_color: Color = Color(1, 1, 0, 1)
@export var passive_effect_id: StringName = &"none"
@export var passive_threshold: int = 0
@export var passive_radius: float = 0.0
@export var passive_duration: float = 0.0
@export var passive_execute_health_ratio: float = 0.0
@export var passive_boss_damage_scale: float = 1.0
@export var passive_bleed_duration: float = 0.0
@export var passive_bleed_damage_scale: float = 0.0
@export var skill_charge_time: float = 0.0
@export var skill_effect_id: StringName = &"none"
@export var skill_cooldown: float = 0.0
@export var skill_duration: float = 0.0
@export var skill_range: float = 0.0
@export var skill_radius: float = 0.0
@export var skill_boss_damage_scale: float = 1.0
@export var skill_damage_bonus_per_kill: int = 0
@export var skill_attack_speed_multiplier: float = 1.0
@export var light_attack: Resource
@export var followup_attack: Resource
@export var finisher_attack: Resource
@export var skill_display_name: String = "Skill"
@export var skill_attack: Resource
@export var ultimate_display_name: String = "Ultimate"
@export var ultimate_energy_cost: int = 100
@export var ultimate_hold_time: float = 0.45
@export var ultimate_attacks: Array[Resource] = []

func attack_chain() -> Array:
	var chain: Array = []
	for attack in [light_attack, followup_attack, finisher_attack]:
		if attack != null:
			chain.append(attack)
	return chain


func skill_cost() -> int:
	if skill_attack == null:
		return 0
	return skill_attack.energy_cost


func ultimate_attack_chain() -> Array:
	var chain: Array = []
	for attack: Resource in ultimate_attacks:
		if attack != null:
			chain.append(attack)
	return chain


func has_ultimate() -> bool:
	return not ultimate_attack_chain().is_empty()


func resolved_world_texture() -> Texture2D:
	if world_texture != null:
		return world_texture
	return icon_texture


func resolved_hud_icon() -> Texture2D:
	if hud_icon != null:
		return hud_icon
	if world_texture != null:
		return world_texture
	return icon_texture
