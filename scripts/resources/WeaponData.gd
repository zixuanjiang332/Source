class_name WeaponData
extends Resource

@export var weapon_id: StringName = &"weapon"
@export var display_name := "Weapon"
@export_multiline var description := ""
@export var light_attack: Resource
@export var followup_attack: Resource
@export var finisher_attack: Resource
@export var skill_display_name := "Skill"
@export var skill_attack: Resource

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
