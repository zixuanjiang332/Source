extends Node

const DEFAULT_KEYMAP := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"jump": [KEY_SPACE],
	"dash": [KEY_SHIFT],
	"attack": [KEY_J],
	"skill": [KEY_K],
	"restart": [KEY_R],
	"pause": [KEY_ESCAPE],
}

func _ready() -> void:
	for action in DEFAULT_KEYMAP:
		_ensure_action(action, DEFAULT_KEYMAP[action])


func _ensure_action(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)

	for keycode: int in keys:
		if _has_key_event(action, keycode):
			continue

		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action, event)


func _has_key_event(action: StringName, keycode: int) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return true
	return false
