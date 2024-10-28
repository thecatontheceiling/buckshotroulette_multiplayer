class_name MP_SeparateLerp extends Node

@export var obj : Node3D
var dur = .3
var curve_value_y_active = -2
var elapsed = 0
var pos_current : Vector3
var pos_next : Vector3
var rot_current : Vector3
var rot_next : Vector3
var moving = false
var counting = false
var timer = 0

func StartLerp(from_pos : Vector3, to_pos : Vector3, from_rot : Vector3, to_rot : Vector3, curve_value_y : float = -2, duration_override : float = .3):
	dur = duration_override
	curve_value_y_active = curve_value_y
	pos_current = from_pos
	pos_next = to_pos
	rot_current = from_rot
	rot_next = to_rot
	elapsed = 0
	timer = 0
	moving = true
	counting = true

func StopLerp():
	moving = false
	counting = false
	timer = 0

func SnapToNextPosition():
	moving = false
	obj.transform.origin = pos_next
	obj.rotation_degrees = rot_next

func Failsafe():
	moving = false
	counting = false
	timer = 0

func _process(delta):
	Lerp()
	Timeout()

func Timeout():
	if counting:
		timer += get_process_delta_time()
		if timer > dur:
			OnTimeout()

func OnTimeout():
	counting = false
	timer = 0
	SnapToNextPosition()

func Lerp():
	if moving:
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0, 1.0)
		var c_y = clampf(elapsed / dur, 0.0, 1.0)
		c = ease(c, -2)
		c_y = ease(c, curve_value_y_active)
		var x = lerp(pos_current.x, pos_next.x, c)
		var y = lerp(pos_current.y, pos_next.y, c_y)
		var z = lerp(pos_current.z, pos_next.z, c)
		var pos = Vector3(x, y, z)
		var rot = lerp(rot_current, rot_next, c)
		obj.transform.origin = pos
		obj.rotation_degrees = rot
