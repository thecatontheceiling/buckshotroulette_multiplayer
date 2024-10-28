class_name MP_UserStateManager extends Node

@export var properties : MP_UserInstanceProperties
@export var nametag : Label3D
@export var cam : Camera3D

@export_group("INSIDE_INSTANCE SET STATE")
@export var array_inside_obj : Array[Node3D]
@export var array_inside_ui : Array[Control]
@export_group("OUTSIDE_INSTANCE SET STATE")
@export var array_outside_obj : Array[Node3D]
@export var array_outside_ui : Array[Control]

func _ready():
	SetState()

func SetState():
	for i in array_outside_obj: i.visible = !properties.is_active
	for i in array_outside_ui: i.visible = !properties.is_active
	for i in array_inside_obj: i.visible = properties.is_active
	for i in array_inside_ui: i.visible = properties.is_active
	if (nametag != null): nametag.text = properties.user_name.left(19)
	#cam.current = properties.is_active

func SetCameraAsCurrent():
	cam.current = true
