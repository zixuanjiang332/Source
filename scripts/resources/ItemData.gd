class_name ItemData
extends Resource

@export var item_id: StringName = &"item"
@export var display_name: String = "Prototype Item"
@export_multiline var description: String = ""
@export var icon_id: StringName = &"placeholder"
@export var is_accessory: bool = false
@export var effect_id: StringName = &"damage_multiplier"
@export var magnitude: float = 1.0
@export var stackable: bool = true
@export var revive_health_ratio: float = 0.5
@export var revive_health_flat: int = 0
@export var revive_energy_ratio: float = 0.0
@export var revive_energy_flat: int = 0
@export var revive_priority: int = 0
@export var revive_invulnerability: float = 1.2
@export var revive_delay: float = 0.18
@export var revive_vfx_id: StringName = &"dash_burst"
@export var revive_sfx_id: StringName = &""
@export_multiline var revive_toast: String = ""
