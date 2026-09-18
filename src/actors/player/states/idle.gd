extends State

var player: PlayerController

func enter(_msg: Dictionary = {}) -> void:
	player = actor as PlayerController
	player.velocity.x = 0.0
	player.velocity.z = 0.0

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_attack"):
		machine.transit(&"attack", {"kind": &"light_1"})
	elif event.is_action_pressed("heavy_attack"):
		machine.transit(&"attack", {"kind": &"heavy"})
	elif event.is_action_pressed("dodge"):
		machine.transit(&"dodge")

func physics_update(delta: float) -> void:
	player.face_lock(delta)
	if player.guard_held:
		machine.transit(&"guard")
		return
	var wish := player.move_vector()
	if wish.length() > 0.15:
		machine.transit(&"move")
