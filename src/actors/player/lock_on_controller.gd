class_name LockOnController
extends Node

@export var camera: OrbitCamera
@export var origin: Node3D
@export var radius: float = 16.0
@export var max_angle_deg: float = 70.0

var target: Node3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("lock_on"):
		if target:
			clear()
		else:
			acquire()

func acquire() -> void:
	var best: Node3D
	var best_score := -INF
	var forward := camera.planar_forward()
	for node in get_tree().get_nodes_in_group("lockable"):
		if node == origin or not node is Node3D:
			continue
		var n3 := node as Node3D
		if n3.has_method("is_dead") and n3.is_dead():
			continue
		var to: Vector3 = n3.global_position - origin.global_position
		var dist := to.length()
		if dist > radius or dist < 0.4:
			continue
		to.y = 0.0
		var dir := to.normalized()
		var ang := rad_to_deg(forward.angle_to(dir))
		if ang > max_angle_deg:
			continue
		var score := (max_angle_deg - ang) * 2.0 + (radius - dist)
		if score > best_score:
			best_score = score
			best = n3
	if best:
		target = best
		camera.lock_target = best
		EventBus.lock_on_changed.emit(best)

func clear() -> void:
	target = null
	if camera:
		camera.lock_target = null
	EventBus.lock_on_changed.emit(null)

func _process(_delta: float) -> void:
	if target == null:
		return
	if not is_instance_valid(target):
		clear()
		return
	if origin.global_position.distance_to(target.global_position) > radius + 4.0:
		clear()
		return
	if target.has_method("is_dead") and target.is_dead():
		clear()
