class_name MP_Viewblocker extends Node

@export var properties : MP_UserInstanceProperties
@export var color_rect : ColorRect
@export var color_max : Color
@export var color_min : Color

var lerping = false
var dur_active = 0
var curve_active = 0
var elapsed = 0
var active_color_start
var active_color_end

func _process(delta):
	Lerp()

func Set():
	active_color_start = color_rect.color
	elapsed = 0
	lerping = false

func FadeIn(duration : float, curve : float):
	Set()
	dur_active = duration
	curve_active = curve
	active_color_end = color_max
	lerping = true

func FadeOut(duration : float, curve : float):
	Set()
	dur_active = duration
	curve_active = curve
	active_color_end = color_min
	lerping = true

func Snap_Transparent():
	Set()
	color_rect.color = color_min

func Snap_Opaque():
	Set()
	color_rect.color = color_max

func Lerp():
	if lerping:
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur_active, 0.0, 1.0)
		c = ease(c, curve_active)
		var col = lerp(active_color_start, active_color_end, c)
		color_rect.color = col

















