extends Node

const DEFAULT_KEYMAP := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"interact": [KEY_E],
	"jump": [KEY_SPACE],
	"dash": [KEY_SHIFT],
	"attack": [MOUSE_BUTTON_LEFT],
	"skill": [MOUSE_BUTTON_RIGHT],
	"reload": [KEY_R],
	"restart": [KEY_F],
	"pause": [KEY_ESCAPE],
	"weapon_slot_1": [KEY_1],
	"weapon_slot_2": [KEY_2],
	"weapon_slot_3": [KEY_3],
	"drop_weapon": [KEY_G],
}

func _ready() -> void:
	for action in DEFAULT_KEYMAP:
		_ensure_action(action, DEFAULT_KEYMAP[action])
	_reconcile_swapped_keys()


func _ensure_action(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)

	for keycode: int in keys:
		# 处理鼠标事件（MOUSE_BUTTON_* 常量）
		if keycode in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			if _has_mouse_event(action, keycode):
				continue
			var event: InputEventMouseButton = InputEventMouseButton.new()
			event.button_index = keycode
			InputMap.action_add_event(action, event)
		# 处理键盘事件（KEY_* 常量）
		else:
			if _has_key_event(action, keycode):
				continue
			var event: InputEventKey = InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)


func _has_key_event(action: StringName, keycode: int) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return true
	return false


func _has_mouse_event(action: StringName, button_index: int) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventMouseButton and event.button_index == button_index:
			return true
	return false


func _reconcile_swapped_keys() -> void:
	_remove_key_event(&"reload", KEY_F)
	_remove_key_event(&"restart", KEY_R)
	_ensure_action(&"reload", [KEY_R])
	_ensure_action(&"restart", [KEY_F])


func _remove_key_event(action: StringName, keycode: int) -> void:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			InputMap.action_erase_event(action, event)
