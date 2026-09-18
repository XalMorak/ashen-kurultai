class_name Hurtbox
extends Area3D

signal received(info: DamageInfo)

@export var team: int = 1
@export var owner_actor: Node

var _seen: Dictionary = {}
var invulnerable: bool = false


func _ready() -> void:
	monitoring = true
	monitorable = true
	collision_layer = 16
	collision_mask = 8
	area_entered.connect(_on_area_entered)


func clear_hit(hit_id: int) -> void:
	_seen.erase(hit_id)


func _on_area_entered(area: Area3D) -> void:
	if invulnerable:
		return
	if not area.has_method("build_damage"):
		return
	var info: DamageInfo = area.build_damage()
	if info == null:
		return
	if info.team == team:
		return
	if _seen.has(info.hit_id):
		return
	_seen[info.hit_id] = true
	received.emit(info)
	if owner_actor and owner_actor.has_method("apply_damage"):
		owner_actor.apply_damage(info)
