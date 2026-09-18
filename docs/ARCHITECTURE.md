# Architecture

Godot 4.3+, Forward+, typed GDScript only.

Layers: Presentation ← Actors ← Resources ← Services (Game, EventBus, SaveService).

Physics layers: 1 world, 2 player, 3 enemy, 4 hitbox, 5 hurtbox, 6 interact.

Damage pipeline: Hitbox → DamageInfo → Hurtbox filters team/hit_id/i-frames → apply → EventBus → Hit or Death.
