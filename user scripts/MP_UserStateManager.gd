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

func _unhandled_input(event):
	if event.is_action_pressed("m") && GlobalVariables.mp_debugging:
		nametag.visible = !nametag.visible

func SetState():
	for i in array_outside_obj: i.visible = !properties.is_active
	for i in array_outside_ui: i.visible = !properties.is_active
	for i in array_inside_obj: i.visible = properties.is_active
	for i in array_inside_ui: i.visible = properties.is_active
	var visible_name = ""
	if nametag != null: 
		if !GlobalVariables.mp_debugging:
			visible_name = Steam.getFriendPersonaName(properties.user_id)
		else:
			visible_name = properties.user_name
		nametag.text = visible_name.left(19)
	#cam.current = properties.is_active

func SetCameraAsCurrent():
	cam.current = true
