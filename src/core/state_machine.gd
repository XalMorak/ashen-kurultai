class_name StateMachine
extends Node

signal state_changed(from: StringName, to: StringName)

@export var initial_state: NodePath

var current: State
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			var state := child as State
			state.machine = self
			state.actor = get_parent()
			states[StringName(state.name.to_lower())] = state
	if initial_state != NodePath():
		var start := get_node_or_null(initial_state) as State
		if start:
			current = start
			current.enter()


func _unhandled_input(event: InputEvent) -> void:
	if current:
		current.handle_input(event)


func _process(delta: float) -> void:
	if current:
		current.update(delta)


func _physics_process(delta: float) -> void:
	if current:
		current.physics_update(delta)


func transit(to: StringName, msg: Dictionary = {}) -> void:
	var key := StringName(String(to).to_lower())
	if not states.has(key):
		push_warning("Unknown state: %s" % to)
		return
	var next: State = states[key]
	if next == current:
		return
	var from_name := StringName(current.name) if current else StringName("")
	if current:
		current.exit()
	current = next
	current.enter(msg)
	state_changed.emit(from_name, key)


func is_in(state_name: StringName) -> bool:
	return current != null and current.name.to_lower() == String(state_name).to_lower()
