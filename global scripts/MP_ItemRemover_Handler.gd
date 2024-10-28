class_name MP_ItemRemover_Handler extends Node

@export var root : Node3D
@export var assigned_socket_number : int
@export var animator : AnimationPlayer
@export var blinkers : Array[MP_Blinker]
@export var indicators : Array[Node3D]

func _ready():
	ResetLights()
	root.visible = false

func MoveDown():
	root.visible = true
	animator.play("move down")

func MoveUp():
	animator.play("move up")
	await get_tree().create_timer(1.38, false).timeout
	root.visible = false

func ResetLights():
	for blinker in blinkers:
		blinker.delay = .04
		blinker.obj.visible = false
	for indicator in indicators:
		indicator.visible = false

func LightShow():
	await get_tree().create_timer(1.65, false).timeout
	Blink()
	await get_tree().create_timer(.2, false).timeout
	Blink()
	await get_tree().create_timer(.05, false).timeout
	for blinker in blinkers:
		blinker.StopBlinking()
		blinker.obj.visible = true
	for indicator in indicators:
		indicator.visible = true

func Blink():
	for blinker in blinkers:
		blinker.obj.visible = true
	await get_tree().create_timer(.05, false).timeout
	for blinker in blinkers:
		blinker.obj.visible = false
