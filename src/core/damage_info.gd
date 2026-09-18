class_name DamageInfo
extends RefCounted

enum Team { PLAYER, ENEMY, NEUTRAL }
enum Stance { NONE, LIGHT, HEAVY, CHARGE, THRUST, SWEEP, SPELL, GRAB }

var amount: float = 0.0
var poise_damage: float = 0.0
var stamina_damage: float = 0.0
var knockback: Vector3 = Vector3.ZERO
var hit_id: int = 0
var attacker: Node3D
var team: Team = Team.ENEMY
var stance: Stance = Stance.LIGHT
var can_be_guarded: bool = true
var can_be_perfect_guarded: bool = true
var ignores_poise: bool = false
var attack_name: String = ""


static func make(p_amount: float, p_poise: float, p_attacker: Node3D, p_team: Team, p_hit_id: int) -> DamageInfo:
	var info := DamageInfo.new()
	info.amount = p_amount
	info.poise_damage = p_poise
	info.attacker = p_attacker
	info.team = p_team
	info.hit_id = p_hit_id
	return info
