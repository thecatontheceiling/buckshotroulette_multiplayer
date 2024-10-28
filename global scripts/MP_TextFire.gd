class_name MP_TextFire extends Node

var ui : Control
var speaker : AudioStreamPlayer2D
@export var max_x : float
@export var max_y : float
@export var duration : float
@export var rand_sound_array : Array[AudioStream]

var orig_x : float
var orig_y : float
var moving = false
var elapsed = 0
var low_pitched = false

func _ready():
	speaker = get_parent().get_child(1)
	ui = get_parent()
	
	orig_x = ui.scale.x
	orig_y = ui.scale.y
	ui.scale.x = max_x
	ui.scale.y = max_y

func Reset():
	ui.scale.x = max_x
	ui.scale.y = max_y

func _process(delta):
	Lerp()

func Fire():
	speaker.stream = rand_sound_array[randi_range(0, rand_sound_array.size() - 1)]
	if !low_pitched:	
		speaker.pitch_scale = randf_range(.95, 1)
	else:
		speaker.pitch_scale = 0.2
	speaker.play()
	elapsed = 0
	moving = true
	ui.visible = true

func Lerp():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / duration, 0.0, 1.0)
		c = ease(c, 0.4)
		var temp_x = lerpf(max_x, orig_x, c)
		var temp_y = lerpf(max_y, orig_y, c)
		ui.scale.x = temp_x
		ui.scale.y = temp_y
