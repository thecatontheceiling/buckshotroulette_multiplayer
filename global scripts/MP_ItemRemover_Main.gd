class_name MP_ItemRemover_Main extends Node

@export var root : Node3D
@export var game_state : MP_GameStateManager
@export var socket_rotation_array : Array[Vector3]
@export var socket_cover_lerp_array : Array[MP_SeparateLerp]
@export var machine_instance : PackedScene
@export var blinker_lower : MP_Blinker

@export var speaker_item_remover : AudioStreamPlayer2D

var instance_handler_array : Array[MP_ItemRemover_Handler]
var socket_cover_lerp_duration = .6
var socket_cover_lerp_curve = 1
var socket_cover_position_y_up = 0.412
var socket_cover_position_y_down = -2.9
var carriage_magnet_lerp_duration = .3
var carriage_magnet_lerp_curve = 4.8

func _ready():
	InitialSetup()

func InitialSetup():
	for socket_number in 4:
		var instance = machine_instance.instantiate()
		var handler : MP_ItemRemover_Handler = instance.get_child(0)
		handler.assigned_socket_number = socket_number
		root.add_child.call_deferred(instance)
		instance.rotation_degrees = socket_rotation_array[socket_number]
		instance_handler_array.append(handler)

var debug_count
func RemoveItemsFromSockets(sockets_to_remove_items_at): #array[int]
	#append instances to array for later deletion, clear dictionaries
	print("removing items from sockets: ", sockets_to_remove_items_at)
	var items_to_delete_array = []
	for i in range(sockets_to_remove_items_at.size()):
		for user in game_state.instance_handler.instance_property_array:
			if user.socket_number == sockets_to_remove_items_at[i]:
				print("clearing inventory for: ", user.user_name)
				user.item_manager.ClearInventory_Dictionaries()
		for c in range(game_state.MAIN_inventory_by_socket[sockets_to_remove_items_at[i]].size()):
			if game_state.MAIN_inventory_by_socket[sockets_to_remove_items_at[i]][c] != {}:
				items_to_delete_array.append(game_state.MAIN_inventory_by_socket[sockets_to_remove_items_at[i]][c].item_instance)
	#clear global item count array in the game state
	game_state.SetupEmptyGlobalItemCount()
	#lerp cameras
	for property in game_state.instance_handler.instance_property_array:
		property.cam.BeginLerp("home")
	await get_tree().create_timer(.4, false).timeout
	blinker_lower.StartBlinking()
	sockets_to_remove_items_at.sort()
	#move tabletop padding covers down
	speaker_item_remover.play()
	for remover_socket_index in range(sockets_to_remove_items_at.size()):
		for item_remover in instance_handler_array:
			item_remover.ResetLights()
			if item_remover.assigned_socket_number == sockets_to_remove_items_at[remover_socket_index]:
				var pos_start = Vector3(socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.x, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.y, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.z)
				var pos_end = Vector3(socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.x, socket_cover_position_y_down, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.z)
				var rot = Vector3(socket_cover_lerp_array[item_remover.assigned_socket_number].obj.rotation_degrees.x, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.rotation_degrees.y, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.rotation_degrees.z)
				socket_cover_lerp_array[item_remover.assigned_socket_number].StartLerp(pos_start, pos_end, rot, rot, socket_cover_lerp_curve, socket_cover_lerp_duration)
				break
	#indicator lights, move item removers down
	for remover_socket_index in range(sockets_to_remove_items_at.size()):
		for handler in instance_handler_array:
			if handler.assigned_socket_number == sockets_to_remove_items_at[remover_socket_index]:
				handler.LightShow()
	#move item removers down
	await get_tree().create_timer(socket_cover_lerp_duration, false).timeout
	for remover_socket_index in range(sockets_to_remove_items_at.size()):
		for item_remover in instance_handler_array:
			if sockets_to_remove_items_at[remover_socket_index] == item_remover.assigned_socket_number:
				instance_handler_array[item_remover.assigned_socket_number].MoveDown()
				break
	#shake camera on item remover impact
	await get_tree().create_timer(.23, false).timeout
	for property in game_state.instance_handler.instance_property_array:
		property.cam_shaker.Shake()
	#get property etc
	await get_tree().create_timer(1.2, false).timeout
	for remover_socket_index in range(sockets_to_remove_items_at.size()):
		var instance_array_to_reparent = []
		for local_grid_index in game_state.MAIN_inventory_by_socket[sockets_to_remove_items_at[remover_socket_index]]:
			if local_grid_index != {}:
				instance_array_to_reparent.append(local_grid_index.item_instance)
		var remover_item_parent = instance_handler_array[sockets_to_remove_items_at[remover_socket_index]].get_parent().get_child(2).get_child(0).get_child(0)
		#lerp items to carrier
		for item_instance in instance_array_to_reparent:
			var item_id : int = item_instance.get_child(1).item_id
			var item_lerp : MP_SeparateLerp = item_instance.get_child(2)
			var item_y_offset_from_carriage : float
			for res in game_state.MAIN_item_resource_array:
				if res.id == item_id:
					item_y_offset_from_carriage = res.pos_Y_offset_from_carriage
					break
			var pos_start = Vector3(item_instance.transform.origin.x, item_instance.transform.origin.y, item_instance.transform.origin.z)
			var pos_end = Vector3(item_instance.transform.origin.x, item_y_offset_from_carriage, item_instance.transform.origin.z)
			var rot = item_instance.rotation_degrees
			item_lerp.StartLerp(pos_start, pos_end, rot, rot, carriage_magnet_lerp_curve, carriage_magnet_lerp_duration)
	await get_tree().create_timer(carriage_magnet_lerp_duration, false).timeout
	#parent items to carrier
	for remover_socket_index in range(sockets_to_remove_items_at.size()):
		var instance_array_to_reparent = []
		for local_grid_index in game_state.MAIN_inventory_by_socket[sockets_to_remove_items_at[remover_socket_index]]:
			if local_grid_index != {}:
				instance_array_to_reparent.append(local_grid_index.item_instance)
		for item_instance in instance_array_to_reparent:
			var original_transform = item_instance.global_transform
			item_instance.get_parent().remove_child(item_instance)
			var remover_item_parent = instance_handler_array[sockets_to_remove_items_at[remover_socket_index]].get_parent().get_child(2).get_child(0).get_child(0)
			remover_item_parent.add_child(item_instance)
			item_instance.global_transform = original_transform
	#move item remover carrier up
	for remover_socket_index in range(sockets_to_remove_items_at.size()):
		for item_remover in instance_handler_array:
			if sockets_to_remove_items_at[remover_socket_index] == item_remover.assigned_socket_number:
				instance_handler_array[item_remover.assigned_socket_number].MoveUp()
				break
	await get_tree().create_timer(.6, false).timeout
	#move tabletop padding covers up
	for remover_socket_index in range(sockets_to_remove_items_at.size()):
		for item_remover in instance_handler_array:
			if sockets_to_remove_items_at[remover_socket_index] == item_remover.assigned_socket_number:
				var pos_start = Vector3(socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.x, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.y, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.z)
				var pos_end = Vector3(socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.x, socket_cover_position_y_up, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.transform.origin.z)
				var rot = Vector3(socket_cover_lerp_array[item_remover.assigned_socket_number].obj.rotation_degrees.x, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.rotation_degrees.y, socket_cover_lerp_array[item_remover.assigned_socket_number].obj.rotation_degrees.z)
				socket_cover_lerp_array[item_remover.assigned_socket_number].StartLerp(pos_start, pos_end, rot, rot, socket_cover_lerp_curve, socket_cover_lerp_duration)
				break
	await get_tree().create_timer(.4, false).timeout
	#clear game state main inventory for all sockets
	game_state.SetupInventory()
	#delete instances that were added to array for deletion
	for item_instance in items_to_delete_array:
		item_instance.queue_free()
















