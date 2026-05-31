class_name VfxCatalog
extends Resource

@export var fallback_scene: PackedScene
@export var hit_spark_scene: PackedScene
@export var dash_burst_scene: PackedScene
@export var item_pickup_scene: PackedScene

func scene_for(vfx_id: StringName) -> PackedScene:
	match vfx_id:
		&"hit_spark_metal":
			return hit_spark_scene if hit_spark_scene != null else fallback_scene
		&"dash_burst":
			return dash_burst_scene if dash_burst_scene != null else fallback_scene
		&"item_pickup":
			return item_pickup_scene if item_pickup_scene != null else fallback_scene
		_:
			return fallback_scene
