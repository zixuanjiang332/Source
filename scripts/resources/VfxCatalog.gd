class_name VfxCatalog
extends Resource

@export var fallback_scene: PackedScene
@export var hit_spark_scene: PackedScene
@export var dash_burst_scene: PackedScene
@export var item_pickup_scene: PackedScene
@export var skill_cast_default_scene: PackedScene
@export var skill_katana_flash_scene: PackedScene
@export var skill_stiletto_overclock_scene: PackedScene
@export var skill_next_gen_burst_scene: PackedScene
@export var skill_surge_armor_pierce_scene: PackedScene
@export var sheet_entries: Array[VfxEntry] = []
@export var sfx_entries: Array[SfxEntry] = []

func scene_for(vfx_id: StringName) -> PackedScene:
	match vfx_id:
		&"hit_spark_metal":
			return hit_spark_scene if hit_spark_scene != null else fallback_scene
		&"dash_burst":
			return dash_burst_scene if dash_burst_scene != null else fallback_scene
		&"item_pickup":
			return item_pickup_scene if item_pickup_scene != null else fallback_scene
		&"skill_cast_default":
			return skill_cast_default_scene if skill_cast_default_scene != null else fallback_scene
		&"skill_katana_flash":
			return skill_katana_flash_scene if skill_katana_flash_scene != null else fallback_scene
		&"skill_stiletto_overclock":
			return skill_stiletto_overclock_scene if skill_stiletto_overclock_scene != null else fallback_scene
		&"skill_next_gen_burst":
			return skill_next_gen_burst_scene if skill_next_gen_burst_scene != null else fallback_scene
		&"skill_surge_armor_pierce":
			return skill_surge_armor_pierce_scene if skill_surge_armor_pierce_scene != null else fallback_scene
		_:
			return fallback_scene


func sheet_entry_for(vfx_id: StringName) -> VfxEntry:
	for entry: VfxEntry in sheet_entries:
		if entry != null and entry.vfx_id == vfx_id:
			return entry
	return null


func sfx_entry_for(sfx_id: StringName) -> SfxEntry:
	for entry: SfxEntry in sfx_entries:
		if entry != null and entry.sfx_id == sfx_id:
			return entry
	return null
