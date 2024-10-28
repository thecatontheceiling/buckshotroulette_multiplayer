class_name MP_Blinker extends Node

@export var obj : Node3D
@export var delay : float

func StartBlinking():
	blinking = true
	obj.visible = false
	Blink()

func StopBlinking():
	blinking = false
	obj.visible = false

var blinking = false
func Blink():
	while blinking:
		obj.visible = false
		await get_tree().create_timer(delay, false).timeout
		obj.visible = true
		await get_tree().create_timer(delay, false).timeout
