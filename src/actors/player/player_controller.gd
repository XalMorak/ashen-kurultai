class_name PlayerController
extends CharacterBody3D

const GRAVITY := 18.0
const WALK_SPEED := 4.2
const SPRINT_SPEED := 6.6
const DODGE_SPEED := 9.8
const ROTATE_SPEED := 12.0
const STAMINA_REGEN := 28.0
const STAMINA_REGEN_DELAY := 0.85
const POISE_REGEN := 18.0
const IFRAME_LIGHT := 0.26
const IFRAME_MED := 0.20
const IFRAME_HEAVY := 0.12
const PERFECT_GUARD := 0.18

@onready var camera: OrbitCamera = $OrbitCamera
@onready var mesh: MeshInstance3D = $Body
@onready var machine: StateMachine = $StateMachine
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var lock_on: LockOnController = $LockOn

var stats: ActorStats
var weapon: WeaponData
var health: float
var stamina: float
var poise: float
var max_health: float
var max_stamina: float
var max_poise: float
var i_frames: float = 0.0
var stamina_lock: float = 0.0
var guard_held: bool = false
var guard_time: float = 0.0
var hit_serial: int = 1
var buffered_attack: StringName = &""
var buffer_age: float = 0.0

func _ready() -> void:
	add_to_group("player")
	Game.player = self
	var cls := Game.class_data()
	stats = cls.stats
	weapon = Game.catalog.weapon_by_id(cls.starting_weapon_id)
	Game.flask_max = cls.flask_charges
	Game.flask = cls.flask_charges
	_apply_tint(cls.color)
	full_restore()
	hurtbox.owner_actor = self
	hurtbox.team = DamageInfo.Team.PLAYER
	hitbox.owner_actor = self
	hitbox.team = DamageInfo.Team.PLAYER
	EventBus.flask_changed.emit(Game.flask, Game.flask_max)
	EventBus.ember_changed.emit(Game.ember, Game.ember_on_ground)

func full_restore() -> void:
	max_health = stats.max_health()
	max_stamina = stats.max_stamina()
	max_poise = stats.max_poise()
	health = max_health
	stamina = max_stamina
	poise = max_poise

func _apply_tint(color: Color) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.62
	mat.metallic = 0.12
	mesh.material_override = mat

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	i_frames = maxf(0.0, i_frames - delta)
	hurtbox.invulnerable = i_frames > 0.0
	stamina_lock = maxf(0.0, stamina_lock - delta)
	if stamina_lock <= 0.0 and not guard_held:
		stamina = minf(max_stamina, stamina + STAMINA_REGEN * delta)
	poise = minf(max_poise, poise + POISE_REGEN * delta)
	if buffer_age > 0.0:
		buffer_age -= delta
		if buffer_age <= 0.0:
			buffered_attack = &""
	guard_held = Input.is_action_pressed("guard")
	if guard_held:
		guard_time += delta
	else:
		guard_time = 0.0
	if Input.is_action_just_pressed("use_flask"):
		_drink()
	move_and_slide()

func move_vector() -> Vector3:
	var raw := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish := camera.planar_forward() * -raw.y + camera.planar_right() * raw.x
	if wish.length() > 1.0:
		wish = wish.normalized()
	return wish

func face_direction(dir: Vector3, delta: float) -> void:
	if dir.length() < 0.05:
		return
	var target_yaw := atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, ROTATE_SPEED * delta)

func face_lock(delta: float) -> void:
	if lock_on.target and is_instance_valid(lock_on.target):
		var to := lock_on.target.global_position - global_position
		to.y = 0.0
		face_direction(to.normalized(), delta)

func spend_stamina(cost: float) -> bool:
	if stamina < cost:
		return false
	stamina -= cost
	stamina_lock = STAMINA_REGEN_DELAY
	return true

func buffer(kind: StringName) -> void:
	buffered_attack = kind
	buffer_age = 0.12

func consume_buffer() -> StringName:
	var v := buffered_attack
	buffered_attack = &""
	buffer_age = 0.0
	return v

func start_i_frames() -> void:
	var load_ratio := weapon.weight / stats.equip_budget()
	if load_ratio < 0.30:
		i_frames = IFRAME_LIGHT
	elif load_ratio < 0.70:
		i_frames = IFRAME_MED
	else:
		i_frames = IFRAME_HEAVY

func apply_damage(info: DamageInfo) -> void:
	if i_frames > 0.0:
		return
	var amount := info.amount
	if guard_held and info.can_be_guarded:
		var perfect := guard_time <= PERFECT_GUARD and info.can_be_perfect_guarded
		if perfect:
			stamina = minf(max_stamina, stamina + 8.0)
			EventBus.announcement.emit("Perfect guard")
			return
		var chip := amount * 0.22
		var stam := info.stamina_damage if info.stamina_damage > 0.0 else amount * 0.45
		amount = chip
		if not spend_stamina(stam):
			amount = info.amount
			machine.transit(&"hit", {"info": info})
	health -= amount
	poise -= info.poise_damage
	EventBus.damage_applied.emit(self, info)
	if health <= 0.0:
		machine.transit(&"death", {"info": info})
		return
	if poise <= 0.0:
		poise = max_poise * 0.35
		machine.transit(&"hit", {"info": info})

func _drink() -> void:
	if machine.is_in(&"death") or machine.is_in(&"attack") or machine.is_in(&"hit"):
		return
	if not Game.try_flask():
		EventBus.announcement.emit("Flask empty")
		return
	health = minf(max_health, health + max_health * 0.42)
	EventBus.announcement.emit("Ember Flask")

func is_dead() -> bool:
	return machine.is_in(&"death")

func arm_attack(attack: AttackData) -> void:
	var info := DamageInfo.make(weapon.scaled_damage(stats) * attack.damage_scale, attack.poise_damage, self, DamageInfo.Team.PLAYER, hit_serial)
	info.stance = attack.stance
	info.attack_name = String(attack.id)
	hit_serial += 1
	hitbox.arm(info)

func disarm_attack() -> void:
	hitbox.disarm()
