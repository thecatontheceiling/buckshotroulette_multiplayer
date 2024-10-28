class_name MP_LightController extends Node

@export var light : Light3D

var moving = false
var elapsed = 0
var dur = 0
var energy_start = 0
var energy_end = 0
var active_curve = 0

func _process(delta):
	Lerp()

func LerpEnergy(from : float, to : float, curve : float, duration : float):
	moving = false
	elapsed = 0
	energy_start = from
	energy_end = to
	dur = duration
	active_curve = curve
	moving = true

func Lerp():
	if moving:
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0, 1.0)
		var val = lerp(energy_start, energy_end, c)
		light.light_energy = val
