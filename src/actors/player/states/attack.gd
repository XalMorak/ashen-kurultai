extends State

var player: PlayerController
var attack: AttackData
var time: float = 0.0
var armed: bool = false

func enter(msg: Dictionary = {}) -> void:
	player = actor as PlayerController
	var kind: StringName = msg.get("kind", &"light_1")
	attack = _find(kind)
	if attack == null:
		machine.transit(&"idle")
		return
	if not player.spend_stamina(attack.stamina_cost):
		machine.transit(&"idle")
		return
	time = 0.0
	armed = false
	player.velocity.x = 0.0
	player.velocity.z = 0.0

func exit() -> void:
	player.disarm_attack()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_attack"):
		player.buffer(&"light")
	elif event.is_action_pressed("heavy_attack"):
		player.buffer(&"heavy")
	elif event.is_action_pressed("dodge") and time > attack.hit_end:
		machine.transit(&"dodge")

func physics_update(delta: float) -> void:
	time += delta
	if attack.can_rotate:
		if player.lock_on.target:
			player.face_lock(delta)
		else:
			var wish := player.move_vector()
			if wish.length() > 0.2:
				player.face_direction(wish, delta * 0.45)
	if time >= attack.hit_start and time <= attack.hit_end:
		if not armed:
			player.arm_attack(attack)
			armed = true
			var impulse := -player.global_transform.basis.z * attack.movement_impulse
			player.velocity.x = impulse.x
			player.velocity.z = impulse.z
	else:
		player.disarm_attack()
		player.velocity.x = move_toward(player.velocity.x, 0.0, 20.0 * delta)
		player.velocity.z = move_toward(player.velocity.z, 0.0, 20.0 * delta)
	if time >= attack.combo_window_start and time <= attack.combo_window_end:
		var buf := player.consume_buffer()
		if buf != &"":
			if buf == &"light" and attack.next_combo != &"":
				machine.transit(&"attack", {"kind": attack.next_combo})
				return
			if buf == &"heavy":
				machine.transit(&"attack", {"kind": &"heavy"})
				return
	if time >= attack.duration:
		if player.guard_held:
			machine.transit(&"guard")
		elif player.move_vector().length() > 0.15:
			machine.transit(&"move")
		else:
			machine.transit(&"idle")

func _find(kind: StringName) -> AttackData:
	if player.weapon == null:
		return null
	for a in player.weapon.attacks:
		if a.id == kind:
			return a
	if kind == &"light":
		return _find(&"light_1")
	return player.weapon.attacks[0] if player.weapon.attacks.size() > 0 else null
