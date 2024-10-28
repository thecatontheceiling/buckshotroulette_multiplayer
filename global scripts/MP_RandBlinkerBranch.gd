class_name MP_RandBlinkerBranch extends Node

@export var obj : Node3D
@export var getting_object_from_parent : bool
@export var r1 : float
@export var r2 : float
var looping = false

func _ready():
	if getting_object_from_parent: obj = get_parent()
	looping = true
	Loop()

func Loop():
	while looping:
		obj.visible = false
		await get_tree().create_timer(randf_range(r1, r2), false).timeout
		obj.visible = true
		await get_tree().create_timer(randf_range(r1, r2), false).timeout
