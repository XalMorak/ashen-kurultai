class_name ActorStats
extends Resource

@export var vigor: int = 10
@export var endurance: int = 10
@export var strength: int = 10
@export var dexterity: int = 10
@export var mind: int = 10
@export var faith: int = 10
@export var resonance: int = 10


func max_health() -> float:
	return 280.0 + float(vigor) * 22.0 + maxf(0.0, float(vigor - 40)) * 8.0


func max_stamina() -> float:
	return 80.0 + float(endurance) * 2.4


func max_poise() -> float:
	return 30.0 + float(endurance) * 1.1 + float(strength) * 0.4


func equip_budget() -> float:
	return 40.0 + float(endurance) * 1.5
