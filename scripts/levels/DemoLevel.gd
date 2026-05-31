class_name DemoLevel
extends Node2D

@onready var route_label: Label = $RouteLabel

func _ready() -> void:
	route_label.text = "Foundry access route // art-first combat slice"
