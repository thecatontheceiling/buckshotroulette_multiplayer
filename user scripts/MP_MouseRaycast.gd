class_name MP_MouseRaycast extends Camera3D

@export var properties : MP_UserInstanceProperties
@export var checkingOverride : bool
@export var cursor : MP_CursorManager
var mouse = Vector2()
var result = null

var controller_overriding = false
var eventpos : Vector2

var pos_previous : Vector2
var velocity : Vector2
var getting_selection = true
var mouse_raycast_previously_active = true

func _input(event):
	if event is InputEventMouse && properties.is_active:
		if(!controller_overriding): 
			mouse = event.position
			eventpos = event.position

func _unhandled_input(event):
	if GlobalVariables.mp_debugging && properties.is_active:
		if event.is_action_pressed("debug_b"):
			print("mouse pos: ", mouse)

func _process(delta):
	if properties.is_active && getting_selection:
		get_selection()

func SetMouseRaycast(state : bool):
	mouse_raycast_previously_active = state
	getting_selection = state
	properties.interaction.checking = state
	if !state:
		ClearMouseActiveProperties()

func ClearMouseActiveProperties():
	properties.interaction.activeInteractionBranch = null
	result = null
	if properties.description.started:
		properties.description.EndLerp()

func get_selection():
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 20000)
	result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	#if result != {}: print(result.values()[3].get_parent().name)

func GetRaycastOverride(pos_override : Vector2):
	controller_overriding = true
	mouse = pos_override

func StopRaycastOverride():
	controller_overriding = false
