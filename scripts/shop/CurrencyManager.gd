extends Node

var _credits: int = 500

func _ready() -> void:
	GameEvents.report_currency_changed(_credits)


func get_balance() -> int:
	return _credits


func can_afford(amount: int) -> bool:
	return _credits >= amount


func spend(amount: int) -> bool:
	if not can_afford(amount):
		return false
	_credits -= amount
	GameEvents.report_currency_changed(_credits)
	return true


func add(amount: int) -> void:
	_credits = mini(_credits + amount, 9999)
	GameEvents.report_currency_changed(_credits)
