class_name SfxEntry
extends Resource

@export var sfx_id: StringName = &"sfx"
@export var stream: AudioStream
@export_range(-36.0, 12.0, 0.5) var volume_db := 0.0
@export_range(0.5, 2.0, 0.01) var pitch_scale := 1.0
