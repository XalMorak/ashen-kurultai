extends State

var player: PlayerController
var time: float = 0.0

func enter(_msg: Dictionary = {}) -> void:
	player = actor as PlayerController
	time = 0.0
	player.velocity = Vector3.ZERO
	player.i_frames = 10.0
	for old in player.get_tree().get_nodes_in_group("ember_drops"):
		old.queue_free()
	if Game.ember_on_ground > 0:
		Game.lose_ground_ember()
	var dropped := Game.drop_ember_on_death()
	EventBus.actor_died.emit(player, null)
	EventBus.announcement.emit("You died — ember left on the ash")
	_spawn_drop(dropped)

func physics_update(delta: float) -> void:
	time += delta
	if time > 2.4:
		_respawn()

func _spawn_drop(amount: int) -> void:
	if amount <= 0:
		return
	var drop := preload("res://scenes/world/ember_drop.tscn").instantiate()
	drop.amount = amount
	player.get_tree().current_scene.add_child(drop)
	drop.global_position = player.global_position + Vector3.UP * 0.4

func _respawn() -> void:
	var stones := player.get_tree().get_nodes_in_group("ember_stones")
	var dest: Node3D
	for s in stones:
		if s.has_method("stone_id") and s.stone_id() == Game.last_stone_id:
			dest = s
			break
	if dest == null and stones.size() > 0:
		dest = stones[0]
	if dest:
		player.global_position = dest.global_position + Vector3(1.6, 0.2, 0.0)
	player.full_restore()
	machine.transit(&"idle")
	EventBus.announcement.emit("Returned to Ember Stone")
