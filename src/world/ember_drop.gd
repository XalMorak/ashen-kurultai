class_name EmberDrop
extends Area3D

var amount: int = 0
var claimed: bool = false

func _ready() -> void:
	add_to_group("ember_drops")
	collision_layer = 32
	collision_mask = 2
	body_entered.connect(_on_enter)

func _on_enter(body: Node3D) -> void:
	if claimed or not body.is_in_group("player"):
		return
	claimed = true
	Game.reclaim_ember()
	EventBus.announcement.emit("Ember reclaimed")
	queue_free()
