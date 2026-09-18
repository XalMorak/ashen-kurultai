extends Node

func _ready() -> void:
	_key("move_left", KEY_A)
	_key("move_right", KEY_D)
	_key("move_forward", KEY_W)
	_key("move_back", KEY_S)
	_key("sprint", KEY_SHIFT)
	_key("dodge", KEY_SPACE)
	_key("guard", KEY_CTRL)
	_key("lock_on", KEY_Q)
	_key("use_flask", KEY_R)
	_key("interact", KEY_E)
	_key("pause_menu", KEY_ESCAPE)
	_mouse("light_attack", MOUSE_BUTTON_LEFT)
	_mouse("heavy_attack", MOUSE_BUTTON_RIGHT)
	_mouse("lock_on", MOUSE_BUTTON_MIDDLE)

func _ensure(name: String) -> void:
	if not InputMap.has_action(name):
		InputMap.add_action(name)

func _key(name: String, keycode: Key) -> void:
	_ensure(name)
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(name, ev)

func _mouse(name: String, button: MouseButton) -> void:
	_ensure(name)
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(name, ev)
