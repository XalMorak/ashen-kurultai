class_name Hitbox
extends Area3D

@export var team: int = 0
@export var owner_actor: Node

var active: bool = false
var current: DamageInfo


func _ready() -> void:
	monitoring = true
	monitorable = true
	collision_layer = 8
	collision_mask = 0


func arm(info: DamageInfo) -> void:
	current = info
	active = true
	monitoring = true


func disarm() -> void:
	active = false
	current = null


func build_damage() -> DamageInfo:
	if not active:
		return null
	return current
