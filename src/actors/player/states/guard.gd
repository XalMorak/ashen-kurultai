extends State

var player: PlayerController

func enter(_msg: Dictionary = {}) -> void:
	player = actor as PlayerController
	player.velocity.x = 0.0
	player.velocity.z = 0.0

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("dodge"):
		machine.transit(&"dodge")
	elif event.is_action_pressed("light_attack"):
		machine.transit(&"attack", {"kind": &"light_1"})

func physics_update(delta: float) -> void:
	player.face_lock(delta)
	var wish := player.move_vector()
	if wish.length() > 0.1:
		var planar := wish * player.WALK_SPEED * 0.45
		player.velocity.x = planar.x
		player.velocity.z = planar.z
		player.face_direction(wish, delta)
	else:
		player.velocity.x = 0.0
		player.velocity.z = 0.0
	if not player.guard_held:
		machine.transit(&"idle")
