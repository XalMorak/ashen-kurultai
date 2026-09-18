extends State

var player: PlayerController
var time: float = 0.0
var dir: Vector3 = Vector3.FORWARD
const DURATION := 0.42

func enter(_msg: Dictionary = {}) -> void:
	player = actor as PlayerController
	if not player.spend_stamina(22.0):
		machine.transit(&"idle")
		return
	time = 0.0
	dir = player.move_vector()
	if dir.length() < 0.1:
		dir = -player.global_transform.basis.z
	dir.y = 0.0
	dir = dir.normalized()
	player.start_i_frames()
	player.face_direction(dir, 1.0)

func physics_update(delta: float) -> void:
	time += delta
	var planar := dir * player.DODGE_SPEED * (1.0 - time / DURATION * 0.35)
	player.velocity.x = planar.x
	player.velocity.z = planar.z
	if time >= DURATION:
		var next := player.consume_buffer()
		if next != &"":
			machine.transit(&"attack", {"kind": next})
		elif player.move_vector().length() > 0.15:
			machine.transit(&"move")
		else:
			machine.transit(&"idle")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_attack"):
		player.buffer(&"light_1")
	elif event.is_action_pressed("heavy_attack"):
		player.buffer(&"heavy")
