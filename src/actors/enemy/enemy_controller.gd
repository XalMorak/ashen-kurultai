class_name EnemyController
extends CharacterBody3D

const GRAVITY := 18.0

@export var data_id: StringName = &"hollow_banner"

@onready var mesh: MeshInstance3D = $Body
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox

var data: EnemyData
var health: float
var poise: float
var home: Vector3
var target: Node3D
var attack_cd: float = 0.0
var attacking: bool = false
var attack_t: float = 0.0
var hit_serial: int = 1000
var dead: bool = false

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("lockable")
	data = Game.catalog.enemy_by_id(data_id)
	if data == null:
		push_error("Missing enemy data %s" % data_id)
		return
	scale = Vector3.ONE * data.scale
	health = data.max_health
	poise = data.max_poise
	home = global_position
	_tint(data.color)
	hurtbox.owner_actor = self
	hurtbox.team = DamageInfo.Team.ENEMY
	hitbox.owner_actor = self
	hitbox.team = DamageInfo.Team.ENEMY
	if data.is_boss:
		add_to_group("bosses")

func _tint(color: Color) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.7
	mesh.material_override = mat

func _physics_process(delta: float) -> void:
	if dead:
		return
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	attack_cd = maxf(0.0, attack_cd - delta)
	poise = minf(data.max_poise, poise + 10.0 * delta)
	_acquire()
	if attacking:
		_tick_attack(delta)
	elif target:
		_chase(delta)
	else:
		_home(delta)
	move_and_slide()

func _acquire() -> void:
	var p := Game.player
	if p == null or (p.has_method("is_dead") and p.is_dead()):
		target = null
		return
	var dist := global_position.distance_to(p.global_position)
	if target == null and dist <= data.detect_range:
		target = p
		if data.is_boss:
			EventBus.boss_encounter_started.emit(data.id, data.display_name)
	elif target and dist > data.lose_range:
		target = null
		if data.is_boss:
			EventBus.boss_encounter_ended.emit(data.id, false)

func _chase(delta: float) -> void:
	var to := target.global_position - global_position
	to.y = 0.0
	var dist := to.length()
	if dist > 0.05:
		var dir := to.normalized()
		rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), 6.0 * delta)
	if dist > data.attack_range:
		var planar := to.normalized() * data.move_speed
		velocity.x = planar.x
		velocity.z = planar.z
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if attack_cd <= 0.0:
			_begin_attack()

func _home(delta: float) -> void:
	var to := home - global_position
	to.y = 0.0
	if to.length() > 0.4:
		var planar := to.normalized() * data.move_speed * 0.6
		velocity.x = planar.x
		velocity.z = planar.z
	else:
		velocity.x = 0.0
		velocity.z = 0.0

func _begin_attack() -> void:
	attacking = true
	attack_t = 0.0
	attack_cd = 1.35 if not data.is_boss else 1.8

func _tick_attack(delta: float) -> void:
	attack_t += delta
	velocity.x = 0.0
	velocity.z = 0.0
	if attack_t >= 0.28 and attack_t <= 0.46:
		if not hitbox.active:
			var info := DamageInfo.make(data.damage, data.poise_damage, self, DamageInfo.Team.ENEMY, hit_serial)
			hit_serial += 1
			hitbox.arm(info)
	else:
		hitbox.disarm()
	if attack_t >= 0.85:
		attacking = false
		hitbox.disarm()

func apply_damage(info: DamageInfo) -> void:
	if dead:
		return
	health -= info.amount
	poise -= info.poise_damage
	EventBus.damage_applied.emit(self, info)
	if data.is_boss:
		EventBus.boss_health_changed.emit(health / data.max_health)
	if health <= 0.0:
		_die(info.attacker)
		return
	if poise <= 0.0:
		poise = data.max_poise * 0.4
		attacking = false
		hitbox.disarm()

func _die(killer: Node) -> void:
	dead = true
	hitbox.disarm()
	hurtbox.invulnerable = true
	velocity = Vector3.ZERO
	Game.add_ember(data.ember_reward)
	EventBus.actor_died.emit(self, killer)
	if data.is_boss:
		EventBus.boss_encounter_ended.emit(data.id, true)
		EventBus.announcement.emit("%s — name taken back" % data.display_name)
	mesh.visible = false
	set_deferred("collision_layer", 0)
	await get_tree().create_timer(0.05).timeout
	queue_free()

func is_dead() -> bool:
	return dead

func reset_at_stone() -> void:
	if data.is_boss:
		return
	health = data.max_health
	poise = data.max_poise
	global_position = home
	target = null
	dead = false
