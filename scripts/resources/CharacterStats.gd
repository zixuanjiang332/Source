class_name CharacterStats
extends Resource

@export var display_name := "Unit"
@export var max_health := 100
@export var max_energy := 100
@export var move_speed := 110.0
@export var acceleration := 1800.0
@export var friction := 2200.0
@export var jump_velocity := -520.0
@export var dash_speed := 360.0
@export var dash_duration := 0.12
@export var dash_cooldown := 0.42
@export var gravity_scale := 1.0
@export var contact_damage := 8

func runtime_copy():
	return duplicate(true)
