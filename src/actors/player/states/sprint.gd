extends State

var player: PlayerController

func enter(_msg: Dictionary = {}) -> void:
	player = actor as PlayerController

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("dodge"):
		machine.transit(&"dodge")
	elif event.is_action_pressed("light_attack"):
		machine.transit(&"attack", {"kind": &"light_1"})

func physics_update(delta: float) -> void:
	var wish := player.move_vector()
	if wish.length() < 0.12 or not Input.is_action_pressed("sprint"):
		machine.transit(&"move")
		return
	if not player.spend_stamina(16.0 * delta):
		machine.transit(&"move")
		return
	player.face_direction(wish, delta)
	var planar := wish * player.SPRINT_SPEED
	player.velocity.x = planar.x
	player.velocity.z = planar.z
