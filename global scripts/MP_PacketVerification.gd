class_name MP_PacketVerification extends Node

@export var game_state : MP_GameStateManager
@export var instance_handler : MP_UserInstanceHandler
@export var roundManager : MP_RoundManager
@export var packets : PacketManager

var debug_index = -1

func VerifyPacket(packet_data):
	var id = packet_data.values()[3]
	match id:
		10:
			print("matched id ", id, " in verification. returning after packet: ", packet_data)
	return packet_data

func PacketSort(dict : Dictionary):
	var value_category = dict.values()[0]
	var value_alias = dict.values()[1]
	var packet
	match value_alias:
		"pickup shotgun request":
			packet = {
			"packet category": "MP_UserInstanceProperties",
			"packet alias": "pickup shotgun",
			"sent_from": "host",
			"packet_id": 11,
			"sent_from_socket": dict.sent_from_socket,
			}
		"shoot user request":
			packet = {
				"packet category": "MP_UserInstanceProperties",
				"packet alias": "shoot user",
				"sent_from": "host",
				"packet_id": 13,
				"shooter_socket_self": dict.sent_from_socket,
				"shooter_socket_target": dict.socket_to_shoot,
				"shooter_shell": game_state.MAIN_active_sequence_dict.sequence_in_shotgun[0],
				"shooter_sequence_length_after_eject": game_state.MAIN_active_sequence_dict.sequence_in_shotgun.size() - 1,
				"shooter_socket_target_direction": roundManager.GetDirection(dict.sent_from_socket, dict.socket_to_shoot),
				"barrel_sawed_off": game_state.MAIN_barrel_sawed_off,
				"sent_from_socket": dict.sent_from_socket,
				"ending_turn_after_shot": game_state.CheckIfShooterEndingTurnAfterShot(dict.socket_to_shoot, dict.sent_from_socket, game_state.MAIN_active_sequence_dict.sequence_in_shotgun[0], game_state.MAIN_barrel_sawed_off, game_state.MAIN_active_sequence_dict.sequence_in_shotgun.size() - 1),
				"sequence_in_shotgun": game_state.MAIN_active_sequence_dict.sequence_in_shotgun,
			}
		"look at user request":
			packet = {
				"packet category": "MP_UserInstanceProperties",
				"packet alias": "look at user",
				"sent_from": "host",
				"packet_id": 16,
				"socket_number": dict.sent_from_socket,
				"direction_to_look": dict.direction_to_look,
			}
		"grab item request":
			var item_to_grab = game_state.GetItemToGrab(GetSocketProperties(dict.sent_from_socket), true)
			if item_to_grab == null: return
			#debug here1
			#var debug_properties = GetSocketProperties(dict.sent_from_socket)
			#var temp = [3, 3, 2, 8, 5, 6, 8, 9]
			#temp = [8, 2, 2, 2, 2, 2, 2, 2, 2]
			#if dict.sent_from_socket != 0: temp = [2, 2, 2, 2, 2]
			#debug_properties.debug_index += 1
			#if debug_properties.debug_index == temp.size(): debug_properties.debug_index = 0
			#item_to_grab = temp[debug_properties.debug_index]
			#debug here11
			packet = {
				"packet category": "MP_UserInstanceProperties",
				"packet alias": "grab item",
				"sent_from": "host",
				"packet_id": 18,
				"socket_number": dict.sent_from_socket,
				"item_id": item_to_grab,
			}
		"place item request":
			var is_last_item = game_state.IsPlacingLastItem(GetSocketProperties(dict.sent_from_socket))
			var sockets_ending_item_grabbing = []
			if is_last_item:
				game_state.MAIN_active_num_of_users_finished_item_grabbing += 1
				game_state.CheckIfItemGrabbingFinishedForAllUsers()
				sockets_ending_item_grabbing = game_state.GetSocketArrayToEndItemGrabbingOn(dict.sent_from_socket)
			packet = {
				"packet category": "MP_UserInstanceProperties",
				"packet alias": "place item",
				"sent_from": "host",
				"packet_id": 20,
				"socket_number": dict.sent_from_socket,
				"local_grid_index": dict.local_grid_index,
				"is_last_item": is_last_item,
				"sockets_ending_item_grabbing": sockets_ending_item_grabbing,
			}
		"interact with item request":
			packet = {
				"packet category": "MP_UserInstanceProperties",
				"packet alias": "interact with item",
				"sent_from": "host",
				"packet_id": 23,
				"item_socket_number": dict.item_socket_number,
				"local_grid_index": dict.local_grid_index,
				"item_id": dict.item_id,
				"socket_number": dict.sent_from_socket,
				"stealing_item": dict.stealing_item,
				"ending_turn_after_item_use": game_state.CheckIfEndingTurnAfterItemUse(dict.item_id, dict.sent_from_socket),
				"current_shell_in_chamber": game_state.MAIN_active_sequence_dict.sequence_in_shotgun[0],
			}
		"secondary item interaction request":
			packet = {
				"packet category": "MP_UserInstanceProperties",
				"packet alias": "secondary item interaction",
				"sent_from": "host",
				"packet_id": 25,
				"socket_number": dict.sent_from_socket,
				"item_id": dict.item_id,
				"has_exit_animation": dict.has_exit_animation,
				"item_selected_socket_number": dict.item_selected_socket_number,
				"item_selected_local_grid_index": dict.item_selected_local_grid_index,
				"ending_turn_after_item_use": game_state.CheckIfEndingTurnAfterItemUse(dict.item_id, dict.sent_from_socket),
			}
		"exit to lobby request":
			packet = {
				"packet category": "MP_UserInstanceHandler",
				"packet alias": "exit to lobby",
				"sent_from": "host",
				"packet_id": 29,
			}
	packets.send_p2p_packet(0, packet)
	packets.PipeData(packet)

func GetSocketProperties(socket_number : int):
	for instance_property in instance_handler.instance_property_array:
		if instance_property.socket_number == socket_number:
			return instance_property
