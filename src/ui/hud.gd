extends CanvasLayer

@onready var hp: ProgressBar = $Root/Bars/Health
@onready var sta: ProgressBar = $Root/Bars/Stamina
@onready var ember_label: Label = $Root/Ember
@onready var flask_label: Label = $Root/Flask
@onready var prompt: Label = $Root/Prompt
@onready var banner: Label = $Root/Banner
@onready var boss_wrap: Control = $Root/Boss
@onready var boss_name: Label = $Root/Boss/Name
@onready var boss_hp: ProgressBar = $Root/Boss/Health
@onready var class_title: Label = $Root/ClassTitle

var banner_time: float = 0.0

func _ready() -> void:
	EventBus.ember_changed.connect(_on_ember)
	EventBus.flask_changed.connect(_on_flask)
	EventBus.prompt_changed.connect(func(t: String) -> void: prompt.text = t)
	EventBus.announcement.connect(_announce)
	EventBus.boss_encounter_started.connect(_boss_start)
	EventBus.boss_health_changed.connect(_boss_hp)
	EventBus.boss_encounter_ended.connect(_boss_end)
	boss_wrap.visible = false
	var cls := Game.class_data()
	class_title.text = "%s  ·  %s" % [cls.display_name, cls.title_mn]
	_on_ember(Game.ember, Game.ember_on_ground)
	_on_flask(Game.flask, Game.flask_max)

func _process(delta: float) -> void:
	var p := Game.player as PlayerController
	if p:
		hp.max_value = p.max_health
		hp.value = p.health
		sta.max_value = p.max_stamina
		sta.value = p.stamina
	if banner_time > 0.0:
		banner_time -= delta
		if banner_time <= 0.0:
			banner.text = ""

func _on_ember(current: int, ground: int) -> void:
	if ground > 0:
		ember_label.text = "EMBER  %d   ·   lost %d" % [current, ground]
	else:
		ember_label.text = "EMBER  %d" % current

func _on_flask(current: int, maximum: int) -> void:
	flask_label.text = "FLASK  %d / %d" % [current, maximum]

func _announce(text: String) -> void:
	banner.text = text
	banner_time = 2.6

func _boss_start(_id: StringName, display: String) -> void:
	boss_wrap.visible = true
	boss_name.text = display
	boss_hp.value = 1.0

func _boss_hp(ratio: float) -> void:
	boss_hp.value = ratio

func _boss_end(_id: StringName, _slain: bool) -> void:
	boss_wrap.visible = false
