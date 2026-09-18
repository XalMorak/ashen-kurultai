class_name WeaponData
extends Resource

@export var id: StringName = &"ashen_glaive"
@export var display_name: String = "Ashen Glaive"
@export var weapon_class: StringName = &"polearm"
@export var base_damage: float = 92.0
@export var str_scaling: float = 0.55
@export var dex_scaling: float = 0.35
@export var weight: float = 9.5
@export var stamina_light: float = 18.0
@export var stamina_heavy: float = 28.0
@export var range_meters: float = 2.4
@export var required_str: int = 14
@export var required_dex: int = 12
@export var attacks: Array[AttackData] = []


func scaled_damage(stats: ActorStats) -> float:
	var bonus := base_damage * (stats.strength * str_scaling + stats.dexterity * dex_scaling) * 0.012
	return base_damage + bonus
