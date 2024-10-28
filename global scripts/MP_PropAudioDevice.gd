class_name MP_PropAudioDevice extends Node

@export var array_0 : Array[Node3D]
@export var array_1 : Array[Node3D]

func _ready():
	looping = true
	Loop()

var looping = false
func Loop():
	while looping:
		SetSegments()
		await get_tree().create_timer(.2, false).timeout
	pass

func SetSegments():
	var vol_1 = randi_range(0, array_0.size() - 1)
	var vol_2 = randi_range(0, array_1.size() - 1)
	for i in range(array_0.size()):
		array_0[i].visible = false
	for i in range(array_1.size()):
		array_1[i].visible = false
	for i in range(vol_1):
		array_0[i].visible = true
	for i in range(vol_2):
		array_1[i].visible = true
