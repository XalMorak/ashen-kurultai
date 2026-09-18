class_name OrbitCamera
extends Node3D

@export var target: Node3D
@export var sensitivity: float = 0.12
@export var gamepad_sens: float = 2.4
@export var min_pitch: float = -35.0
@export var max_pitch: float = 55.0
@export var distance: float = 5.2
@export var height: float = 1.6
@export var lock_lerp: float = 8.0

var yaw: float = 0.0
var pitch: float = -12.0
var lock_target: Node3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if lock_target:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clampf(pitch, min_pitch, max_pitch)

func _process(delta: float) -> void:
	if target == null:
		return
	if lock_target and is_instance_valid(lock_target):
		var look := lock_target.global_position - target.global_position
		look.y = 0.0
		if look.length() > 0.05:
			var desired := rad_to_deg(atan2(-look.x, -look.z))
			yaw = lerp_angle(deg_to_rad(yaw), deg_to_rad(desired), lock_lerp * delta)
			yaw = rad_to_deg(yaw)
	else:
		var gx := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var gy := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		if absf(gx) > 0.12 or absf(gy) > 0.12:
			yaw -= gx * gamepad_sens
			pitch -= gy * gamepad_sens
			pitch = clampf(pitch, min_pitch, max_pitch)
	var origin := target.global_position + Vector3.UP * height
	var offset := Vector3(0.0, 0.0, distance)
	offset = offset.rotated(Vector3.RIGHT, deg_to_rad(pitch))
	offset = offset.rotated(Vector3.UP, deg_to_rad(yaw))
	global_position = origin + offset
	look_at(origin)

func planar_forward() -> Vector3:
	var f := -global_transform.basis.z
	f.y = 0.0
	return f.normalized()

func planar_right() -> Vector3:
	var r := global_transform.basis.x
	r.y = 0.0
	return r.normalized()
