class_name DemoLevel
extends Node2D

@onready var route_label: Label = $RouteLabel
@onready var flying_traffic: Node2D = get_node_or_null("City/FlyingTraffic") as Node2D
@onready var holograms: Node2D = get_node_or_null("City/Holograms") as Node2D

func _ready() -> void:
	route_label.text = "Awakening route // lab to surface city"
	call_deferred("_announce_start")


func _announce_start() -> void:
	GameEvents.request_objective("WAKE // speak with Dr. Lin")


func _process(delta: float) -> void:
	_animate_flying_traffic(delta)
	_animate_holograms()


func _animate_flying_traffic(delta: float) -> void:
	if flying_traffic == null:
		return

	var index := 0
	for child in flying_traffic.get_children():
		var vehicle := child as Node2D
		if vehicle == null:
			continue

		vehicle.position.x += (24.0 + float(index) * 8.0) * delta
		if vehicle.position.x > 2380.0:
			vehicle.position.x = 980.0
		index += 1


func _animate_holograms() -> void:
	if holograms == null:
		return

	var ticks := float(Time.get_ticks_msec()) * 0.004
	var index := 0
	for child in holograms.get_children():
		var canvas_item := child as CanvasItem
		if canvas_item == null:
			continue

		canvas_item.modulate.a = 0.58 + sin(ticks + float(index)) * 0.18
		index += 1
