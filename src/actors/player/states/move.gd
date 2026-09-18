extends State

var player: PlayerController

func enter(_msg: Dictionary = {}) -> void:
	player = actor as PlayerController

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_attack"):
		machine.transit(&"attack", {"kind": &"light_1"})
	elif event.is_action_pressed("heavy_attack"):
		machine.transit(&"attack", {"kind": &"heavy"})
	elif event.is_action_pressed("dodge"):
		machine.transit(&"dodge")

func physics_update(delta: float) -> void:
	var wish := player.move_vector()
	if player.guard_held:
		machine.transit(&"guard")
		return
	if wish.length() < 0.12:
		machine.transit(&"idle")
		return
	if Input.is_action_pressed("sprint") and player.stamina > 4.0:
		machine.transit(&"sprint")
		return
	player.face_direction(wish, delta)
	player.face_lock(delta)
	var planar := wish * player.WALK_SPEED
	player.velocity.x = planar.x
	player.velocity.z = planar.z
