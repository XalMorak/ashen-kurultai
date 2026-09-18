class_name EmberStone
extends Area3D

@export var id: StringName = &"stone_kurultai_yard"
@export var title: String = "Burnt Kurultai Yard"

var inside: bool = false

func _ready() -> void:
	add_to_group("ember_stones")
	collision_layer = 32
	collision_mask = 2
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body: Node3D) -> void:
	if body.is_in_group("player"):
		inside = true
		EventBus.prompt_changed.emit("E — Rest at %s" % title)

func _on_exit(body: Node3D) -> void:
	if body.is_in_group("player"):
		inside = false
		EventBus.prompt_changed.emit("")

func _unhandled_input(event: InputEvent) -> void:
	if inside and event.is_action_pressed("interact"):
		Game.rest_at(id)

func stone_id() -> StringName:
	return id
