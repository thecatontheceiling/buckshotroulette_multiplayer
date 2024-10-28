class_name MP_LightFlicker extends Node

@export var energy_r1 : float
@export var energy_r2 : float
@export var delay : float

var light
var flickering = false

func _ready():
	light = get_parent()
	flickering = true
	Flicker()

func Flicker():
	while flickering:
		var energy = randf_range(energy_r1, energy_r2)
		light.light_energy = energy
		await get_tree().create_timer(delay, false).timeout
		pass
	pass
