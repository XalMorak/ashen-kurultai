extends Node

signal damage_applied(target: Node, info: DamageInfo)
signal actor_died(actor: Node, killer: Node)
signal ember_changed(current: int, lost_world: int)
signal flask_changed(current: int, maximum: int)
signal player_rested(stone_id: StringName)
signal lock_on_changed(target: Node3D)
signal boss_encounter_started(boss_id: StringName, display_name: String)
signal boss_health_changed(ratio: float)
signal boss_encounter_ended(boss_id: StringName, slain: bool)
signal prompt_changed(text: String)
signal announcement(text: String)
