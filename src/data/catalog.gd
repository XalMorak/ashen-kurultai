class_name Catalog
extends RefCounted

var classes: Dictionary = {}
var weapons: Dictionary = {}
var enemies: Dictionary = {}

func build() -> void:
	_build_classes()
	_build_weapons()
	_build_enemies()

func class_by_id(id: StringName) -> ClassData:
	return classes.get(id)

func weapon_by_id(id: StringName) -> WeaponData:
	return weapons.get(id)

func enemy_by_id(id: StringName) -> EnemyData:
	return enemies.get(id)

func all_classes() -> Array:
	return classes.values()

func _stats(v: int, e: int, s: int, d: int, m: int, f: int, r: int) -> ActorStats:
	var st := ActorStats.new()
	st.vigor = v
	st.endurance = e
	st.strength = s
	st.dexterity = d
	st.mind = m
	st.faith = f
	st.resonance = r
	return st

func _class(id: String, en: String, mn: String, lore: String, st: ActorStats, weapon: String, flask: int, color: Color) -> void:
	var c := ClassData.new()
	c.id = StringName(id)
	c.display_name = en
	c.title_mn = mn
	c.lore = lore
	c.stats = st
	c.starting_weapon_id = StringName(weapon)
	c.flask_charges = flask
	c.color = color
	classes[c.id] = c

func _weapon(id: String, name: String, wclass: String, dmg: float, str_s: float, dex_s: float, weight: float, rng: float) -> WeaponData:
	var w := WeaponData.new()
	w.id = StringName(id)
	w.display_name = name
	w.weapon_class = StringName(wclass)
	w.base_damage = dmg
	w.str_scaling = str_s
	w.dex_scaling = dex_s
	w.weight = weight
	w.range_meters = rng
	w.attacks = _default_attacks()
	weapons[w.id] = w
	return w

func _enemy(id: String, en: String, mn: String, hp: float, poise: float, speed: float, dmg: float, ember: int, color: Color, scale: float = 1.0, boss: bool = false) -> void:
	var e := EnemyData.new()
	e.id = StringName(id)
	e.display_name = en
	e.title_mn = mn
	e.max_health = hp
	e.max_poise = poise
	e.move_speed = speed
	e.damage = dmg
	e.ember_reward = ember
	e.color = color
	e.scale = scale
	e.is_boss = boss
	if boss:
		e.detect_range = 28.0
		e.lose_range = 40.0
		e.attack_range = 3.2
	enemies[e.id] = e

func _atk(id: String, dmg: float, poise: float, cost: float, dur: float, hs: float, he: float, next: String = "") -> AttackData:
	var a := AttackData.new()
	a.id = StringName(id)
	a.damage_scale = dmg
	a.poise_damage = poise
	a.stamina_cost = cost
	a.duration = dur
	a.hit_start = hs
	a.hit_end = he
	a.next_combo = StringName(next)
	return a

func _default_attacks() -> Array[AttackData]:
	return [
		_atk("light_1", 1.00, 12.0, 16.0, 0.52, 0.14, 0.28, "light_2"),
		_atk("light_2", 1.08, 14.0, 18.0, 0.56, 0.16, 0.30, "light_3"),
		_atk("light_3", 1.22, 18.0, 22.0, 0.70, 0.20, 0.36, ""),
		_atk("heavy", 1.55, 28.0, 30.0, 0.92, 0.34, 0.52, ""),
		_atk("charge", 2.10, 42.0, 38.0, 1.20, 0.55, 0.78, ""),
	]

func _build_classes() -> void:
	_class("fallen_kheshig", "Fallen Kheshig", "Унасан хэшиг", "Imperial guard who failed the last watch.", _stats(16, 12, 16, 9, 7, 8, 6), "ashen_glaive", 5, Color(0.55, 0.16, 0.12))
	_class("ash_shaman", "Ash Shaman", "Үнсэн бөө", "A sky-rite priest whose prayers return as cinders.", _stats(9, 9, 7, 10, 16, 14, 12), "charred_drum", 4, Color(0.62, 0.42, 0.78))
	_class("silent_marksman", "Silent Marksman", "Чимээгүй мэргэн", "Scout who shot the wrong messenger.", _stats(10, 12, 8, 16, 9, 7, 8), "black_recurve", 4, Color(0.28, 0.38, 0.28))
	_class("iron_smith", "Iron Smith", "Төмөр дархан", "Foundry exile. Charged heavies wear hyper armor.", _stats(14, 11, 18, 8, 6, 6, 7), "anvil_star", 5, Color(0.45, 0.45, 0.48))
	_class("night_qarachi", "Night Qarachi", "Шөнийн хараач", "Banner-thief. Criticals from the back.", _stats(9, 13, 8, 17, 8, 6, 10), "twin_sickles", 3, Color(0.12, 0.12, 0.16))
	_class("steppe_exile", "Steppe Exile", "Талын цөллөгч", "Walked away before the pyre. Quality steel.", _stats(12, 12, 12, 12, 9, 9, 8), "road_saber", 5, Color(0.72, 0.55, 0.32))
	_class("bone_chanter", "Bone Chanter", "Яс дуучин", "Resonance caster. A brief ash-hound answers.", _stats(8, 9, 7, 9, 12, 11, 18), "femur_bell", 4, Color(0.78, 0.72, 0.62))
	_class("broken_noyan", "Broken Noyan", "Эвдэрсэн ноён", "Commander without an army.", _stats(13, 11, 13, 11, 10, 10, 9), "banner_spear", 5, Color(0.55, 0.38, 0.18))

func _build_weapons() -> void:
	_weapon("ashen_glaive", "Ashen Glaive", "polearm", 96.0, 0.55, 0.35, 9.5, 2.6)
	_weapon("charred_drum", "Charred Drum", "catalyst", 54.0, 0.10, 0.15, 3.2, 8.0)
	_weapon("black_recurve", "Black Recurve", "bow", 68.0, 0.10, 0.70, 4.4, 18.0)
	_weapon("anvil_star", "Anvil Star", "great", 118.0, 0.80, 0.10, 14.0, 2.2)
	_weapon("twin_sickles", "Twin Sickles", "dual", 72.0, 0.15, 0.75, 4.8, 1.8)
	_weapon("road_saber", "Road Saber", "straight", 84.0, 0.40, 0.45, 6.5, 2.1)
	_weapon("femur_bell", "Femur Bell", "catalyst", 50.0, 0.05, 0.10, 3.6, 7.0)
	_weapon("banner_spear", "Split Banner-Spear", "polearm", 90.0, 0.45, 0.40, 8.2, 2.7)

func _build_enemies() -> void:
	_enemy("hollow_banner", "Hollow Banner", "Хөндий тугчин", 170.0, 28.0, 2.5, 26.0, 38, Color(0.42, 0.28, 0.18))
	_enemy("ash_hound", "Ash Hound", "Үнсэн нохой", 90.0, 12.0, 4.4, 18.0, 22, Color(0.22, 0.18, 0.16), 0.7)
	_enemy("watch_kheshig", "Watch Kheshig", "Харуулын хэшиг", 260.0, 55.0, 2.1, 32.0, 84, Color(0.50, 0.18, 0.14), 1.15)
	_enemy("foundry_brute", "Foundry Brute", "Цутгахын хүчит", 340.0, 70.0, 1.7, 42.0, 110, Color(0.35, 0.35, 0.38), 1.35)
	_enemy("night_cutter", "Night Cutter", "Шөнийн огтлогч", 140.0, 18.0, 3.6, 24.0, 56, Color(0.12, 0.12, 0.14), 0.95)
	_enemy("sky_acolyte", "Sky Acolyte", "Тэнгэрийн шавь", 150.0, 20.0, 2.3, 30.0, 64, Color(0.48, 0.36, 0.62))
	_enemy("horse_wraith", "Horse Wraith", "Морь сүнс", 220.0, 40.0, 5.2, 36.0, 96, Color(0.55, 0.48, 0.40), 1.4)
	_enemy("oovo_warden", "Ovoo Warden", "Овооны харгалзагч", 300.0, 60.0, 2.2, 38.0, 130, Color(0.30, 0.34, 0.28), 1.2)
	_enemy("ember_leech", "Ember Leech", "Ээмбэр шимэгч", 80.0, 8.0, 3.2, 14.0, 18, Color(0.70, 0.28, 0.12), 0.65)
	_enemy("mute_drummer", "Mute Drummer", "Дүлий бөмбөрчин", 160.0, 22.0, 2.0, 16.0, 72, Color(0.38, 0.22, 0.40))
	_enemy("iron_yurt_guard", "Iron Yurt Guard", "Төмөр гэрийн харуул", 280.0, 50.0, 2.0, 34.0, 100, Color(0.40, 0.40, 0.44), 1.1)
	_enemy("cinder_archer", "Cinder Archer", "Цог мэргэн", 130.0, 16.0, 2.4, 22.0, 48, Color(0.36, 0.22, 0.16))
	_enemy("temur_ash", "Hollow Khan Temur-Ash", "Хөндий хан Төмөр-Үнс", 2800.0, 160.0, 2.8, 58.0, 2800, Color(0.62, 0.16, 0.10), 1.8, true)
	_enemy("three_banners", "The Three Banners", "Гурван туг", 2200.0, 120.0, 3.0, 44.0, 2200, Color(0.20, 0.16, 0.14), 1.3, true)
	_enemy("mother_oovo", "Mother of the Silent Ovoo", "Чимээгүй овооны эх", 3200.0, 180.0, 2.2, 62.0, 3400, Color(0.22, 0.30, 0.22), 2.0, true)
	_enemy("slag_noion", "Slag Noion", "Шаар ноён", 3000.0, 200.0, 1.9, 70.0, 3000, Color(0.55, 0.28, 0.10), 1.9, true)
	_enemy("quiet_gate", "The Quiet Gate", "Чимээгүй хаалга", 4000.0, 220.0, 2.5, 66.0, 5000, Color(0.70, 0.62, 0.42), 2.2, true)
