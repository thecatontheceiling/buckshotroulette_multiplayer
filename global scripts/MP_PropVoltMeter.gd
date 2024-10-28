class_name MP_PropVoltMeter extends Node

@export var obj : Node3D
var looping = false
var elapsed = 0
var moving = false
var dur = .3
var min_rot_y = 42.8
var max_rot_y = -45.0
var y_start = 0
var y_end = 0

func _ready():
	looping = true
	Loop()

func _process(delta):
	Lerp()

func Loop():
	while looping:
		moving = false
		y_start = obj.rotation_degrees.y
		y_end = randf_range(min_rot_y, max_rot_y)
		elapsed = 0
		moving = true
		await get_tree().create_timer(dur, false).timeout
		moving = false
		y_start = obj.rotation_degrees.y
		y_end = min_rot_y
		elapsed = 0
		moving = true
		await get_tree().create_timer(dur, false).timeout

func Lerp():
	if moving:
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0, 1.0)
		var rot = lerp(y_start, y_end, c)
		obj.rotation_degrees = Vector3(obj.rotation_degrees.x, rot, obj.rotation_degrees.z)
