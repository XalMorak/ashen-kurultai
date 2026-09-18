extends Node

const Catalog = preload("res://src/data/catalog.gd")

var catalog: Catalog
var selected_class_id: StringName = &"steppe_exile"
var ember: int = 0
var ember_on_ground: int = 0
var flask: int = 5
var flask_max: int = 5
var last_stone_id: StringName = &"stone_kurultai_yard"
var player: Node3D
var paused: bool = false


func _ready() -> void:
	catalog = Catalog.new()
	catalog.build()
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		paused = not paused
		get_tree().paused = paused
		EventBus.announcement.emit("Paused" if paused else "")


func class_data() -> ClassData:
	return catalog.class_by_id(selected_class_id)


func add_ember(amount: int) -> void:
	ember += maxi(0, amount)
	EventBus.ember_changed.emit(ember, ember_on_ground)


func spend_ember(amount: int) -> bool:
	if ember < amount:
		return false
	ember -= amount
	EventBus.ember_changed.emit(ember, ember_on_ground)
	return true


func drop_ember_on_death() -> int:
	var dropped := ember
	ember_on_ground = dropped
	ember = 0
	EventBus.ember_changed.emit(ember, ember_on_ground)
	return dropped


func reclaim_ember() -> void:
	ember += ember_on_ground
	ember_on_ground = 0
	EventBus.ember_changed.emit(ember, ember_on_ground)


func lose_ground_ember() -> void:
	ember_on_ground = 0
	EventBus.ember_changed.emit(ember, ember_on_ground)


func refill_flask() -> void:
	flask = flask_max
	EventBus.flask_changed.emit(flask, flask_max)


func try_flask() -> bool:
	if flask <= 0 or player == null:
		return false
	flask -= 1
	EventBus.flask_changed.emit(flask, flask_max)
	return true


func rest_at(stone_id: StringName) -> void:
	last_stone_id = stone_id
	refill_flask()
	if player and player.has_method("full_restore"):
		player.full_restore()
	EventBus.player_rested.emit(stone_id)
	EventBus.announcement.emit("Ember Stone — the wind stills")
	get_tree().call_group("enemies", "reset_at_stone")
