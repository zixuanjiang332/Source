class_name DashBurst
extends Node2D

@export var lifetime: float = 0.16

func _ready() -> void:
	for i in range(4):
		var line: Line2D = Line2D.new()
		line.width = 2.0
		line.default_color = Color(0.2, 0.85, 1.0, 0.85)
		var y: float = randf_range(-18.0, 8.0)
		line.points = PackedVector2Array([Vector2(18.0, y), Vector2(-28.0, y + randf_range(-4.0, 4.0))])
		add_child(line)

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, lifetime)
	tween.parallel().tween_property(self, "position:x", position.x - 12.0, lifetime)
	tween.finished.connect(queue_free)
