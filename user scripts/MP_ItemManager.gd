class_name MP_ItemManager extends Node

@export var properties : MP_UserInstanceProperties
@export var perms : MP_UserPermissions
@export var item_spawn_parent_local : Node3D
@export var intbranch_intake : MP_InteractionBranch
@export var intbranch_grid_colliders : Array[MP_InteractionBranch]
@export var animator_briefcase : AnimationPlayer
@export var animator_briefcase_tp : AnimationPlayer
@export var animator_items_thirdperson : AnimationPlayer
@export var animator_items_firstperson : AnimationPlayer
@export var shotgun : MP_ShotgunInteraction

@export var bp_item_distribution : Control
@export var btn_briefcase_intake : Control

@export var speaker_fp_item_briefcase : AudioStreamPlayer2D
@export var speaker_tp_item_briefcase : AudioStreamPlayer2D

@export var speaker_fp_place_item_on_table : AudioStreamPlayer2D
@export var speaker_tp_place_item_on_table : AudioStreamPlayer3D
@export var speaker_fp_grab_item_on_table : AudioStreamPlayer2D
@export var speaker_tp_grab_item_on_table : AudioStreamPlayer3D
@export var speaker_fp_initial_interaction : AudioStreamPlayer2D
@export var speaker_tp_initial_interaction : AudioStreamPlayer3D

@export var sound_fp_place : AudioStream
@export var sound_fp_take : AudioStream
@export var sound_tp_place : AudioStream
@export var sound_tp_take : AudioStream

@export var sounds_grab_item : Array[AudioStream]
@export var speaker_fp_grab_item : AudioStreamPlayer2D
@export var speaker_tp_grab_item : AudioStreamPlayer3D

var active_hand : String = "R"

#	ID	NAME
#	1	handsaw
#	2	magnifying glass
#	3	jammer
#	4	cigarettes
#	5	beer
#	6	burner phone
#	7	expired medicine
#	8	adrenaline
#	9	inverter
#	10	remote

func _ready():
	SetIntakeCollider(false)
	SetGridColliders(false)
	for c in item_spawn_parent_local.get_children():
		if c.name != "pos_item pickup":
			c.queue_free()
	await get_tree().create_timer(10, false).timeout

var debug_grid_index = -1
var ind = -1
var g_ind = 0
var ar = [1, 2, 3, 4, 5, 6, 9]
func _unhandled_input(event):
	if GlobalVariables.mp_debug_keys_enabled:
		if event.is_action_pressed("debug_t"):
			if !properties.is_active && properties.health_current != 0:
				await get_tree().create_timer(randf_range(0, 1.0), false).timeout
				GrabItemRequest()
		if event.is_action_pressed("debug_y"):
			if !properties.is_active && properties.health_current != 0:
				await get_tree().create_timer(randf_range(0, 1.0), false).timeout
				debug_grid_index += 1
				if properties.intermediary.game_state.MAIN_inventory_by_socket[properties.socket_number][debug_grid_index] != {}:
					debug_grid_index += 1
				if debug_grid_index == 9:
					debug_grid_index = 0
				PlaceItemRequest(debug_grid_index)
		if event.is_action_pressed("debug_pgdn") && properties.is_active:
			properties.intermediary.game_state.MAIN_active_sequence_dict.sequence_in_shotgun = ["live", "live", "live", "live", "live", "live", "live", "live", ]
			properties.intermediary.game_state.MAIN_active_sequence_dict.sequence_in_shotgun = ["live", "live"]
			if properties.intermediary.game_state.MAIN_active_sequence_dict != null:
				if properties.intermediary.game_state.MAIN_active_sequence_dict.has("sequence_in_shotgun"):
					print ("sequence in shotgun: ", properties.intermediary.game_state.MAIN_active_sequence_dict.sequence_in_shotgun)
		if event.is_action_pressed("debug_pgup") && properties.is_active:
			properties.intermediary.game_state.MAIN_active_sequence_dict.sequence_in_shotgun = ["blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", ]
			if properties.intermediary.game_state.MAIN_active_sequence_dict != null:
				if properties.intermediary.game_state.MAIN_active_sequence_dict.has("sequence_in_shotgun"):
					print ("sequence in shotgun: ", properties.intermediary.game_state.MAIN_active_sequence_dict.sequence_in_shotgun)
		if event.is_action_pressed("debug_home") && properties.is_active:
			properties.intermediary.game_state.PrintInventory()
	
func BeginItemGrabbing():
	print("begin item grabbing on user name: ", properties.user_name)
	properties.is_grabbing_items = true
	debug_grid_index = -1
	if !properties.running_fast_revival:
		#await get_tree().create_timer(1.3, false).timeout
		pass
	#if properties.death.user_reviving: await get_tree().create_timer(2.72, false).timeout
	properties.num_of_items_currently_grabbed = 0
	if properties.is_active:
		properties.inspection.SetInspectObject(false)
		animator_briefcase.play("place briefcase")
		speaker_fp_item_briefcase.stream = sound_fp_place
		speaker_fp_item_briefcase.play()
		properties.cam.BeginLerp("item briefcase")
		await get_tree().create_timer(1.1, false).timeout
		
		bp_item_distribution.visible = true
		if properties.cursor.controller_active: btn_briefcase_intake.grab_focus()
		properties.controller.previousFocus = btn_briefcase_intake
		
		GlobalVariables.cursor_state_after_toggle = true
		properties.cursor.SetCursor(true, true)
		print("set cursor true in item grab")
		SetIntakeCollider(true)
		SetGridColliders(false)
	else:
		animator_briefcase_tp.play("place briefcase third person")
		speaker_tp_item_briefcase.stream = sound_tp_place
		speaker_tp_item_briefcase.play()

func EndItemGrabbing():
	bp_item_distribution.visible = false
		
	if properties.is_holding_item_to_place:
		if active_instance != null:
			ReturnItemToBriefcase()
	properties.intermediary.game_state.StopTimeoutForSocket("item distribution", properties.socket_number)
	SetGridColliders(false)
	SetIntakeCollider(false)
	perms.SetMainPermission(false)
	await get_tree().create_timer(.4, false).timeout
	animator_briefcase.play("return briefcase")
	speaker_fp_item_briefcase.stream = sound_fp_take
	speaker_fp_item_briefcase.play()
	await get_tree().create_timer(.3, false).timeout
	properties.cam.BeginLerp("home")

func ReturnItemToBriefcase():
	PlayItemPullSound_FirstPerson()
	active_separate_lerp.StartLerp(active_instance.transform.origin, active_res.pos_in_briefcase_local, active_instance.rotation_degrees, active_res.rot_in_briefcase_local)
	await get_tree().create_timer(.4, false).timeout
	active_instance.queue_free()

func EndItemGrabbingDefault():
	properties.is_grabbing_items = false
	if properties.is_active:
		EndItemGrabbing()
	else:
		properties.hands.Hands_ReturnBriefcase()

func EndItemGrabbingAfterTimeout():
	properties.is_grabbing_items = false
	if properties.is_active:
		EndItemGrabbing()
	else:
		properties.hands.Hands_ReturnBriefcase()

	if GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
		print("checking")
		properties.intermediary.game_state.MAIN_active_num_of_users_finished_item_grabbing += 1
		properties.intermediary.game_state.CheckIfItemGrabbingFinishedForAllUsers()

func EndItemGrabbingAfterNonEligible():
	properties.is_grabbing_items = false
	if properties.is_active:
		EndItemGrabbing()
	else:
		properties.hands.Hands_ReturnBriefcase()

func GrabItemRequest():
	SetIntakeCollider(false)
	SetGridColliders(false)
	var packet = {
		"packet category": "MP_PacketVerification",
		"packet alias": "grab item request",
		"sent_from": "client",
		"packet_id": 17,
		"sent_from_socket": properties.socket_number,
	}
	properties.intermediary.packets.send_p2p_packet_directly_to_host(GlobalSteam.STEAM_ID, packet)
	if GlobalVariables.mp_debugging: properties.intermediary.packets.PipeData(packet)

func PlaceItemRequest(on_grid_index):
	SetIntakeCollider(false)
	SetGridColliders(false)
	var packet = {
		"packet category": "MP_PacketVerification",
		"packet alias": "place item request",
		"sent_from": "client",
		"packet_id": 19,
		"sent_from_socket": properties.socket_number,
		"local_grid_index": on_grid_index,
	}
	properties.intermediary.packets.send_p2p_packet_directly_to_host(GlobalSteam.STEAM_ID, packet)
	if GlobalVariables.mp_debugging: properties.intermediary.packets.PipeData(packet)

func ReceivePacket_GrabItem(dict : Dictionary):
	if dict.socket_number == properties.socket_number:
		properties.is_holding_item_to_place = true
		properties.num_of_items_currently_grabbed += 1
		if properties.is_active:
			GrabItem(dict.item_id)
			PlayItemPullSound_FirstPerson()
		else:
			if active_hand == "R": active_hand = "L"
			else: active_hand = "R"
			properties.hands.Hand_GrabItem(dict.item_id, active_hand)
			properties.item_manager.PlayItemPullSound_ThirdPerson()

func ReceivePacket_PlaceItem(dict : Dictionary):
	if properties.socket_number in dict.sockets_ending_item_grabbing:
		EndItemGrabbingAfterNonEligible()
	if dict.socket_number == properties.socket_number:
		properties.is_holding_item_to_place = false
		if properties.is_active:
			PlaceItem(dict.local_grid_index, dict.is_last_item)
		else:
			properties.hands.Hand_PlaceItem(dict.local_grid_index, dict.is_last_item)

var active_id = 0
var active_res : MP_ItemResource
var active_separate_lerp : MP_SeparateLerp
var active_instance
func GrabItem(item_id : int):
	active_id = item_id
	for i in properties.intermediary.game_state.MAIN_item_resource_array:
		if i.id == active_id:
			active_res = i
			break
	active_instance = active_res.instance.instantiate()
	var pickup_indicator : MP_PickupIndicator = active_instance.get_child(0)
	pickup_indicator.snapping_to_min = false #set snapping to min false so that interacting is less wonky
	active_separate_lerp = active_instance.get_child(2)
	item_spawn_parent_local.add_child(active_instance)
	active_instance.transform.origin = active_res.pos_in_briefcase_local
	active_instance.rotation_degrees = active_res.rot_in_briefcase_local
	active_separate_lerp.StartLerp(active_instance.transform.origin, active_res.pos_out_briefcase_local, active_instance.rotation_degrees, active_res.rot_out_briefcase_local)
	await get_tree().create_timer(active_separate_lerp.dur, false).timeout
	SetIntakeCollider(false)
	SetGridColliders(true)

func PlaceItem(on_local_index : int, is_last_item : bool = false):
	var item_inventory_dictionary = {
		"item_id": active_id,
		"item_local_grid_index": on_local_index,
	}
	
	var active_stream : AudioStream
	for res in properties.intermediary.game_state.MAIN_item_resource_array:
		if res.id == active_id:
			active_stream = res.sound_place_down_fp
	speaker_fp_place_item_on_table.stream = active_stream
	speaker_fp_place_item_on_table.pitch_scale = randf_range(0.95, 1)
	speaker_fp_place_item_on_table.play()
	
	properties.user_inventory[on_local_index] = item_inventory_dictionary
	properties.user_inventory_instance_array[on_local_index] = active_instance
	properties.intermediary.game_state.Global_AddItemToInventory(properties.socket_number, active_instance, active_id, on_local_index)
	active_instance.get_child(1).local_grid_index = on_local_index
	active_instance.get_child(1).socket_number = properties.socket_number
	
	active_separate_lerp.StartLerp(active_instance.transform.origin, active_res.pos_grid_offset_array_local[on_local_index], active_instance.rotation_degrees, active_res.rot_grid_offset_array_local[on_local_index])
	if is_last_item:
		EndItemGrabbing()
		return
	else:
		if properties.cursor.controller_active: btn_briefcase_intake.grab_focus()
		properties.controller.previousFocus = btn_briefcase_intake
		SetGridColliders(false)
		SetIntakeCollider(true)

func PlayItemPullSound_FirstPerson():
	speaker_fp_grab_item.pitch_scale = randf_range(.95, 1)
	speaker_fp_grab_item.stream = sounds_grab_item[randi_range(0, sounds_grab_item.size() - 1)]
	speaker_fp_grab_item.play()

func PlayItemPullSound_ThirdPerson():
	speaker_tp_grab_item.pitch_scale = randf_range(.95, 1)
	speaker_tp_grab_item.stream = sounds_grab_item[randi_range(0, sounds_grab_item.size() - 1)]
	speaker_tp_grab_item.play()

func ClearInventory_Dictionaries():
	for i in range(properties.user_inventory.size()):
		if properties.user_inventory[i] != null:
			properties.user_inventory[i] = {}
	for i in range(properties.user_inventory_instance_array.size()):
		if properties.user_inventory_instance_array[i] != null:
			properties.user_inventory_instance_array[i] = null
	properties.CLearInventory_Count()

func SetIntakeCollider(enabling : bool):
	intbranch_intake.interactionAllowed = enabling

func SetGridColliders(enabling : bool):
	if enabling:
		for i in range(intbranch_grid_colliders.size()):
			if properties.user_inventory[i] == {}:
				intbranch_grid_colliders[i].interactionAllowed = true
			else:
				intbranch_grid_colliders[i].interactionAllowed = false
	else:
		for i in range(intbranch_grid_colliders.size()):
			intbranch_grid_colliders[i].interactionAllowed = false

func Debug_SpawnItemSeparately(item_id : int, local_grid_index : int):
	var item_resource : MP_ItemResource
	for i in properties.intermediary.game_state.MAIN_item_resource_array:
		if i.id == item_id:
			item_resource = i
			break
	
	active_instance = item_resource.instance.instantiate()
	properties.user_inventory_instance_array[local_grid_index] = active_instance
	properties.item_manager.item_spawn_parent_local.add_child(active_instance)
	active_instance.transform.origin = item_resource.pos_grid_offset_array_local[local_grid_index]
	active_instance.rotation_degrees = item_resource.rot_grid_offset_array_local[local_grid_index]
	active_instance.get_child(1).local_grid_index = local_grid_index
	active_instance.get_child(1).socket_number = properties.socket_number
	
	properties.intermediary.game_state.Global_AddItemToInventory(properties.socket_number, active_instance, item_id, local_grid_index)

func Debug_RemoveItemSeparately(local_grid_index : int):
	properties.user_inventory_instance_array[local_grid_index].queue_free()
	properties.item_interaction.RemoveItemFromInventory(local_grid_index, properties.socket_number)
