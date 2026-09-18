extends Control

@onready var list: VBoxContainer = $Panel/List
@onready var lore: Label = $Panel/Lore
@onready var start_btn: Button = $Panel/Start

var selected: StringName = &"steppe_exile"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for cls in Game.catalog.all_classes():
		var btn := Button.new()
		btn.text = "%s    ·    %s" % [cls.display_name, cls.title_mn]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_pick.bind(cls.id))
		list.add_child(btn)
	start_btn.pressed.connect(_start)
	_pick(&"steppe_exile")

func _pick(id: StringName) -> void:
	selected = id
	Game.selected_class_id = id
	var cls := Game.catalog.class_by_id(id)
	lore.text = "%s\n%s\n\n%s\nFlask %d  ·  Weapon %s" % [cls.display_name, cls.title_mn, cls.lore, cls.flask_charges, cls.starting_weapon_id]

func _start() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_file("res://scenes/world/ashen_yard.tscn")
