extends State

var player: PlayerController
var time: float = 0.0
const DURATION := 0.38

func enter(msg: Dictionary = {}) -> void:
	player = actor as PlayerController
	time = 0.0
	var info: DamageInfo = msg.get("info")
	if info and info.attacker and is_instance_valid(info.attacker):
		var away := player.global_position - info.attacker.global_position
		away.y = 0.0
		if away.length() > 0.01:
			away = away.normalized()
			player.velocity.x = away.x * 6.0
			player.velocity.z = away.z * 6.0

func physics_update(delta: float) -> void:
	time += delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, 18.0 * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, 18.0 * delta)
	if time >= DURATION:
		machine.transit(&"idle")
