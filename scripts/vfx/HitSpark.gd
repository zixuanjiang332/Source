class_name HitSpark
extends Node2D

@export var lifetime: float = 0.18
@export var spark_count: int = 7
@export var color_a: Color = Color(0.25, 1.0, 1.0, 1.0)
@export var color_b: Color = Color(1.0, 0.18, 0.34, 1.0)

func _ready() -> void:
	for i in range(spark_count):
		var line: Line2D = Line2D.new()
		line.width = 2.0 if i % 2 == 0 else 1.0
		line.default_color = color_a.lerp(color_b, randf())
		line.points = PackedVector2Array([
			Vector2.ZERO,
			Vector2(randf_range(8.0, 26.0), 0.0).rotated(randf_range(-1.1, 1.1)),
		])
		add_child(line)

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.35, 1.35), lifetime)
	tween.parallel().tween_property(self, "modulate:a", 0.0, lifetime)
	tween.finished.connect(queue_free)
