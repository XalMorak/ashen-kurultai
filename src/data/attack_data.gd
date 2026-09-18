class_name AttackData
extends Resource

@export var id: StringName = &"light_1"
@export var display_name: String = "Light"
@export var damage_scale: float = 1.0
@export var poise_damage: float = 12.0
@export var stamina_cost: float = 18.0
@export var duration: float = 0.55
@export var hit_start: float = 0.16
@export var hit_end: float = 0.32
@export var next_combo: StringName = &""
@export var combo_window_start: float = 0.34
@export var combo_window_end: float = 0.52
@export var movement_impulse: float = 2.4
@export var can_rotate: bool = true
@export var hyper_armor: bool = false
@export var stance: int = 1
