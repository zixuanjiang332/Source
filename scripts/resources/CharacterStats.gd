class_name CharacterStats
extends Resource

@export var display_name: String = "Unit"
@export var max_health: int = 100
@export var max_energy: int = 100
@export var move_speed: float = 110.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_velocity: float = -520.0
@export var dash_speed: float = 360.0
@export var dash_duration: float = 0.12
@export var dash_cooldown: float = 0.42
@export var gravity_scale: float = 1.0
@export var contact_damage: int = 8

func runtime_copy() -> CharacterStats:
	return duplicate(true)
