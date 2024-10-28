class_name MP_HandManager extends Node

@export var properties : MP_UserInstanceProperties
@export var anim_drop : AnimationPlayer
@export var anim_item_briefcase : AnimationPlayer
@export var separate_lerp_head : MP_SeparateLerp
@export_group("default variables")
@export var default_pos_L : Vector3
@export var default_pos_R : Vector3
@export var default_rot_L : Vector3
@export var default_rot_R : Vector3
@export var hand_parent_L : Node3D
@export var hand_parent_R : Node3D
@export var hand_parent_default_R : Node3D
@export var hand_parent_default_L : Node3D
@export var hand_parent_L_on_shotgun : Node3D
@export var hand_parent_R_on_shotgun : Node3D
@export var rot_head_grid_R : Vector3
@export var rot_head_grid_L : Vector3
@export var rot_head_grabbing_briefcase : Vector3
@export_group("item variables RIGHT")
@export var lerp_R : MP_SeparateLerp #duration changed on ready
@export var pos_grid_offset_array_R : Array[Vector3]
@export var rot_grid_offset_array_R : Array[Vector3]
@export var pos_in_briefcase_R : Vector3
@export var rot_in_briefcase_R : Vector3
@export_group("item variables LEFT")
@export var lerp_L : MP_SeparateLerp #duration changed on ready
@export var pos_grid_offset_array_L : Array[Vector3]
@export var rot_grid_offset_array_L : Array[Vector3]
@export var pos_in_briefcase_L : Vector3
@export var rot_in_briefcase_L : Vector3
@export_group("item variables stealing RIGHT")
@export var pos_grid_offset_array_R_socket_left : Array[Vector3]
@export var pos_grid_offset_array_R_socket_forward : Array[Vector3]
@export var pos_grid_offset_array_R_socket_right : Array[Vector3]
@export var rot_grid_offset_array_R_socket_left : Array[Vector3]
@export var rot_grid_offset_array_R_socket_forward : Array[Vector3]
@export var rot_grid_offset_array_R_socket_right : Array[Vector3]
@export_group("item variables stealing LEFT")
@export var pos_grid_offset_array_L_socket_left : Array[Vector3]
@export var pos_grid_offset_array_L_socket_forward : Array[Vector3]
@export var pos_grid_offset_array_L_socket_right : Array[Vector3]
@export var rot_grid_offset_array_L_socket_left : Array[Vector3]
@export var rot_grid_offset_array_L_socket_forward : Array[Vector3]
@export var rot_grid_offset_array_L_socket_right : Array[Vector3]

var active_hand_main_parent : Node3D
var active_hand_default : Node3D
var active_pos_default : Vector3
var active_rot_default : Vector3
var active_hand : Node3D
var active_mesh : Node3D
var active_grab_resource : MP_ItemResource_User
var active_lerp : MP_SeparateLerp
var active_pos_grid_offset_array : Array[Vector3]
var active_rot_grid_offset_array : Array[Vector3]
var active_pos_in_briefcase : Vector3
var active_rot_in_briefcase : Vector3
var lerp_duration = 0.34
var lerp_duration_item_grabbing = 0.2

func _ready():
	hand_parent_L.transform.origin = default_pos_L
	hand_parent_R.transform.origin = default_pos_R
	hand_parent_L.rotation_degrees = default_rot_L
	hand_parent_R.rotation_degrees = default_rot_R
	lerp_R.dur = lerp_duration
	lerp_L.dur = lerp_duration

func Hand_GrabItem(id : int, which_hand : String):
	for res in properties.user_item_resource_array:
		if res.id == id:
			active_grab_resource = res
			break
	var head_original_rot = separate_lerp_head.obj.rotation_degrees
	active_id = id
	AssignHand(id, which_hand)
	active_lerp.StartLerp(active_hand_main_parent.transform.origin, active_pos_in_briefcase, active_hand_main_parent.rotation_degrees, active_rot_in_briefcase, 4.8, lerp_duration_item_grabbing)
	separate_lerp_head.StartLerp(separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.rotation_degrees, rot_head_grabbing_briefcase, 4.8, lerp_duration_item_grabbing)
	await get_tree().create_timer(lerp_duration_item_grabbing, false).timeout
	active_hand_default.visible = false
	active_hand.visible = true
	active_mesh.visible = true
	active_lerp.StartLerp(active_hand_main_parent.transform.origin, active_pos_default, active_hand_main_parent.rotation_degrees, active_rot_default, 0.2, lerp_duration_item_grabbing)
	separate_lerp_head.StartLerp(separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.rotation_degrees, head_original_rot, 4.8, lerp_duration_item_grabbing)

func Hand_PlaceItem(local_grid_index: int, is_last_item : bool = false):
	if is_last_item:
		properties.intermediary.game_state.StopTimeoutForSocket("item distribution", properties.socket_number)
	var item_inventory_dictionary = {
		"item_id": active_id,
		"item_local_grid_index": local_grid_index,
	}
	
	var active_stream :  AudioStream
	for res in properties.intermediary.game_state.MAIN_item_resource_array:
		if res.id == active_id:
			active_stream = res.sound_place_down_tp
	properties.item_manager.speaker_tp_place_item_on_table.stream = active_stream
	properties.item_manager.speaker_tp_place_item_on_table.pitch_scale = randf_range(0.95, 1)
	properties.item_manager.speaker_tp_place_item_on_table.play()
	
	properties.user_inventory[local_grid_index] = item_inventory_dictionary
	var direction_to_look_at = GetLocalGridDirection(local_grid_index)
	var head_original_rot = separate_lerp_head.obj.rotation_degrees
	var active_grid_direction_rot : Vector3
	if direction_to_look_at == "R":
		active_grid_direction_rot = rot_head_grid_R
	else:
		active_grid_direction_rot = rot_head_grid_L
	var temp_y = properties.user_item_array_offset_y[active_id]
	var local_grid_position = Vector3(active_pos_grid_offset_array[local_grid_index].x, temp_y, active_pos_grid_offset_array[local_grid_index].z)
	active_lerp.StartLerp(active_hand_main_parent.transform.origin, local_grid_position, active_hand_main_parent.rotation_degrees, active_rot_grid_offset_array[local_grid_index], 4.8, lerp_duration_item_grabbing)
	separate_lerp_head.StartLerp(separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.rotation_degrees, active_grid_direction_rot, 4.8, lerp_duration_item_grabbing)
	await get_tree().create_timer(lerp_duration_item_grabbing, false).timeout
	active_hand.visible = false
	active_mesh.visible = false
	active_hand_default.visible = true
	SpawnItemSeparatelyAtGrid(local_grid_index)
	active_lerp.StartLerp(active_hand_main_parent.transform.origin, active_pos_default, active_hand_main_parent.rotation_degrees, active_rot_default, 0.2, lerp_duration_item_grabbing)
	separate_lerp_head.StartLerp(separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.rotation_degrees, head_original_rot, 4.8, lerp_duration_item_grabbing)
	await get_tree().create_timer(lerp_duration_item_grabbing, false).timeout
	if is_last_item: 
		Hands_ReturnBriefcase()

var active_id : int
var active_res : MP_ItemResource
var active_instance
func SpawnItemSeparatelyAtGrid(local_grid_index : int):
	for i in properties.intermediary.game_state.MAIN_item_resource_array:
		if i.id == active_id:
			active_res = i
			break
	
	active_instance = active_res.instance.instantiate()
	properties.user_inventory_instance_array[local_grid_index] = active_instance
	properties.item_manager.item_spawn_parent_local.add_child(active_instance)
	properties.intermediary.game_state.Global_AddItemToInventory(properties.socket_number, active_instance, active_instance.get_child(1).item_id, local_grid_index)
	active_instance.transform.origin = active_res.pos_grid_offset_array_local[local_grid_index]
	active_instance.rotation_degrees = active_res.rot_grid_offset_array_local[local_grid_index]
	active_instance.get_child(1).local_grid_index = local_grid_index
	active_instance.get_child(1).socket_number = properties.socket_number

func Hand_PickupItem(local_grid_index : int, id : int, which_hand : String, item_object : Node3D = null):
	var stealing_item = item_object.get_child(1).socket_number != properties.socket_number
	var item_socket_number = item_object.get_child(1).socket_number
	AssignHand(id, which_hand)
	var active_grid_direction_rot : Vector3
	var direction_to_look_at = GetLocalGridDirection(local_grid_index)
	var head_original_rot = separate_lerp_head.obj.rotation_degrees
	if direction_to_look_at == "R":
		active_grid_direction_rot = Vector3(10.5, -9, 0.2)
	else:
		active_grid_direction_rot = Vector3(10.5, 9.6, 0.2)
	var temp_y = properties.user_item_array_offset_y[active_id]
	var local_grid_position
	var local_grid_rotation
	local_grid_position = Vector3(active_pos_grid_offset_array[local_grid_index].x, temp_y, active_pos_grid_offset_array[local_grid_index].z)
	local_grid_rotation = active_rot_grid_offset_array[local_grid_index]
	if stealing_item:
		var item_direction = properties.GetDirection(properties.socket_number, item_socket_number)
		match item_direction:
			"left":
				active_grid_direction_rot = Vector3(10.5, 9.6, 0.2)
			"forward":
				active_grid_direction_rot = Vector3(0, 0, 0)
			"right":
				active_grid_direction_rot = Vector3(10.5, -9, 0.2)
		var stealing_variable_dictionary = GetStealingVariableDictionary(item_direction, item_object.get_child(1).which_hand_to_grab_with, local_grid_index, temp_y)
		local_grid_position = stealing_variable_dictionary.local_grid_position
		local_grid_rotation = stealing_variable_dictionary.local_grid_rotation
	active_lerp.StartLerp(active_hand_main_parent.transform.origin, local_grid_position, active_hand_main_parent.rotation_degrees, local_grid_rotation, 4.8)
	if active_grid_direction_rot != Vector3(0, 0, 0): separate_lerp_head.StartLerp(separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.rotation_degrees, active_grid_direction_rot, 4.8, lerp_duration_item_grabbing)
	await get_tree().create_timer(lerp_duration, false).timeout
	item_object.queue_free()
	active_hand_default.visible = false
	active_hand.visible = true
	active_mesh.visible = true
	if stealing_item:
		for user_property in properties.intermediary.instance_handler.instance_property_array:
			if user_property.socket_number != properties.socket_number:
				user_property.LookAtSocket(properties.socket_number, true)
	active_lerp.StartLerp(active_hand_main_parent.transform.origin, active_pos_default, active_hand_main_parent.rotation_degrees, active_rot_default, 0.2)
	
	var active_stream : AudioStream
	for res in properties.intermediary.game_state.MAIN_item_resource_array:
		if res.id == id:
			active_stream = res.sound_pick_up_tp
	properties.item_manager.speaker_tp_grab_item_on_table.stream = active_stream
	properties.item_manager.speaker_tp_grab_item_on_table.play()
	
	separate_lerp_head.StartLerp(separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.transform.origin, separate_lerp_head.obj.rotation_degrees, head_original_rot, 4.8, lerp_duration_item_grabbing)
	await get_tree().create_timer(lerp_duration, false).timeout
	active_lerp.moving = false

func AssignHand(id : int, which_hand : String):
	if which_hand == "R":
		active_hand_main_parent = hand_parent_R
		active_hand_default = hand_parent_default_R
		active_pos_default = default_pos_R
		active_rot_default = default_rot_R
		active_lerp = lerp_R
		active_pos_grid_offset_array = pos_grid_offset_array_R
		active_rot_grid_offset_array = rot_grid_offset_array_R
		active_pos_in_briefcase = pos_in_briefcase_R
		active_rot_in_briefcase = rot_in_briefcase_R
		active_hand = properties.user_item_array_hand_R[id]
		active_mesh = properties.user_item_array_mesh_R[id]
	else:
		active_hand_main_parent = hand_parent_L
		active_hand_default = hand_parent_default_L
		active_pos_default = default_pos_L
		active_rot_default = default_rot_L
		active_lerp = lerp_L
		active_pos_grid_offset_array = pos_grid_offset_array_L
		active_rot_grid_offset_array = rot_grid_offset_array_L
		active_pos_in_briefcase = pos_in_briefcase_L
		active_rot_in_briefcase = rot_in_briefcase_L
		active_hand = properties.user_item_array_hand_L[id]
		active_mesh = properties.user_item_array_mesh_L[id]

func ResetItemHands():
	for hand in properties.user_item_array_hand_L:
		hand.visible = false
	for item in properties.user_item_array_mesh_L:
		item.visible = false
	for hand in properties.user_item_array_mesh_R:
		hand.visible = false
	for item in properties.user_item_array_mesh_R:
		item.visible = false
	hand_parent_default_L.visible = true
	hand_parent_default_R.visible = true

func Hands_ReturnBriefcase():
	if properties.is_holding_item_to_place:
		ResetItemHands()
	lerp_L.Failsafe()
	lerp_R.Failsafe()
	hand_parent_R.transform.origin = default_pos_R
	hand_parent_R.rotation_degrees = default_rot_R
	hand_parent_L.transform.origin = default_pos_L
	hand_parent_L.rotation_degrees = default_rot_L
	anim_item_briefcase.play("return briefcase third person")
	properties.item_manager.speaker_tp_item_briefcase.stream = properties.item_manager.sound_tp_place
	properties.item_manager.speaker_tp_item_briefcase.play()

func Hands_DropShotgun():
	Hands_ResetToDefault()
	anim_drop.play("hands drop shotgun")
	properties.oscillator_manager.StartOscillating("hands")
	hand_parent_L.visible = true
	hand_parent_R.visible = true
	hand_parent_L_on_shotgun.visible = false
	hand_parent_R_on_shotgun.visible = false

func Hands_ResetToDefault():
	hand_parent_L.transform.origin = default_pos_L
	hand_parent_R.transform.origin = default_pos_R
	hand_parent_L.rotation_degrees = default_rot_L
	hand_parent_R.rotation_degrees = default_rot_R
	hand_parent_L.visible = true
	hand_parent_R.visible = true
	hand_parent_L_on_shotgun.visible = false
	hand_parent_R_on_shotgun.visible = false

func GetLocalGridDirection(local_grid_index : int):
	var dir = ""
	match local_grid_index:
		0: dir = "L"
		1: dir = "L"
		2: dir = "R"
		3: dir = "R"
		4: dir = "L"
		5: dir = "L"
		6: dir = "R"
		7: dir = "R"
	return dir

func GetStealingVariableDictionary(item_direction : String, which_hand_to_grab_with : String, local_grid_index : int, temp_y : float):
	var local_grid_position
	var local_grid_rotation
	match item_direction:
		"left":
			if which_hand_to_grab_with == "R":
				local_grid_position = Vector3(pos_grid_offset_array_R_socket_left[local_grid_index].x, temp_y, pos_grid_offset_array_R_socket_left[local_grid_index].z)
				local_grid_rotation = rot_grid_offset_array_R_socket_left[local_grid_index]
			else:
				local_grid_position = Vector3(pos_grid_offset_array_L_socket_left[local_grid_index].x, temp_y, pos_grid_offset_array_L_socket_left[local_grid_index].z)
				local_grid_rotation = rot_grid_offset_array_L_socket_left[local_grid_index]
		"right":
			if which_hand_to_grab_with == "R":
				local_grid_position = Vector3(pos_grid_offset_array_R_socket_right[local_grid_index].x, temp_y, pos_grid_offset_array_R_socket_right[local_grid_index].z)
				local_grid_rotation = rot_grid_offset_array_R_socket_right[local_grid_index]
			else:
				local_grid_position = Vector3(pos_grid_offset_array_L_socket_right[local_grid_index].x, temp_y, pos_grid_offset_array_L_socket_right[local_grid_index].z)
				local_grid_rotation = rot_grid_offset_array_L_socket_right[local_grid_index]
		"forward":
			if which_hand_to_grab_with == "R":
				local_grid_position = Vector3(pos_grid_offset_array_R_socket_forward[local_grid_index].x, temp_y, pos_grid_offset_array_R_socket_forward[local_grid_index].z)
				local_grid_rotation = rot_grid_offset_array_R_socket_forward[local_grid_index]
			else:
				local_grid_position = Vector3(pos_grid_offset_array_L_socket_forward[local_grid_index].x, temp_y, pos_grid_offset_array_L_socket_forward[local_grid_index].z)
				local_grid_rotation = rot_grid_offset_array_L_socket_forward[local_grid_index]
	var stealing_variable_dictionary = {
		"local_grid_position": local_grid_position,
		"local_grid_rotation": local_grid_rotation,
	}
	return stealing_variable_dictionary

func Hands_OnUserDeath():
	return
	hand_parent_L.visible = false
	hand_parent_R.visible = false
