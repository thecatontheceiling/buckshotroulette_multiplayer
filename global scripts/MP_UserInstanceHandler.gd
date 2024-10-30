class_name MP_UserInstanceHandler extends Node

@export var packets : PacketManager
@export var round : MP_RoundManager
@export var intro : MP_Intro
@export var active_user : MP_ActiveUserProperties
@export var user_instance : PackedScene
@export var socketArray_rotation : Array[Vector3]
@export var debug : MP_EditorDebug

@export var intermediary : MP_InteractionIntermed

var instance_dictionary = []
var instance_dictionary_test = [] 
var original_host_id = 0

@export var instance_property_array : Array[Node]

var scene_root

func _ready():
	GetRoot()
	if (GlobalVariables.mp_debugging):
		StartMainGame()
	original_host_id = GlobalSteam.HOST_ID

func Setup_ExitGameWithLobbyMembers():
	if GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
		Packet_ExitGameWithLobby()
	else:
		Packet_ExitGameWithLobby_Request()

func ExitGameWithLobby():
	intermediary.ExitGame()

func Packet_ExitGameWithLobby():
	if GlobalSteam.STEAM_ID != GlobalSteam.HOST_ID: return
	var packet = {
		"packet category": "MP_UserInstanceHandler",
		"packet alias": "exit to lobby",
		"sent_from": "host",
		"packet_id": 29,
	}
	packets.send_p2p_packet(0, packet)
	packets.PipeData(packet)

func Packet_ExitGameWithLobby_Request():
	var packet = {
		"packet category": "MP_PacketVerification",
		"packet alias": "exit to lobby request",
		"sent_from": "client",
		"packet_id": 28,
	}
	packets.send_p2p_packet_directly_to_host(GlobalSteam.STEAM_ID, packet)

var removing_instances = true
var previous_member_steamid_array = []
var current_member_steamid_array = []
var instances_to_delete = []
func CheckLobbyMemberArray():
	#if GlobalSteam.STEAM_ID != GlobalSteam.HOST_ID: 
	#	print("is not host. return from check lobby member array")
	#	return
	#print("is host. checking to delete members")
	if GlobalVariables.mp_debugging: current_member_steamid_array = GlobalSteam.LOBBY_MEMBERS.duplicate()
	if previous_member_steamid_array.size() != current_member_steamid_array.size():
		var steamid_array_previous = []
		var steamid_array_current = []
		var steamid_array_deleting = []
		for i in range(previous_member_steamid_array.size()):
			steamid_array_previous.append(previous_member_steamid_array[i].steam_id)
		for i in range(current_member_steamid_array.size()):
			steamid_array_current.append(current_member_steamid_array[i].steam_id)
		for id in steamid_array_previous:
			if !steamid_array_current.has(id): 
				steamid_array_deleting.append(id)
		for id in steamid_array_deleting:
			var property_to_delete = null
			for i in instance_property_array:
				if i.user_id == id: property_to_delete = i
			if property_to_delete != null: 
				print("found instance to delete with assigned steam id: ", property_to_delete.user_id, " and adding to array")
				instances_to_delete.append(property_to_delete.user_id)
		RemoveInstancesFromGame(instances_to_delete)
	intermediary.ingame_lobby_ui.UpdateUserList()

func RemoveInstancesFromGame(instances_to_delete_array : Array):
	if !removing_instances: return
	if instances_to_delete.size() == 0: print("instances to delete array is empty. returning"); return
	print("removing instances from game with array: ", instances_to_delete_array)
	for instance in instance_property_array:
		for id in instances_to_delete_array:
			if instance.user_id == id:
				print("instance user id to disconnect: ", instance.user_id, " host id: ", GlobalSteam.HOST_ID)
				for i in 3:
					print("----------------------------")
				if instance.user_id == original_host_id:
					GlobalVariables.disband_lobby_after_exiting_main_scene = true
					intermediary.ExitGame(tr("MP_CONSOLE EXIT HOST DISCONNECTED"))
					return
				instance.TransferInventoryToGlobalParent()
				debug.SendConsoleMessage(tr("MP_UI PLAYER DISCONNECTED") % instance.user_name)
				CheckToPassTurnAfterUserDisconnect(instance.socket_number)
				instance_property_array.erase(instance)
				instance.instance_root.queue_free()
	for property in instance_property_array:
		if property.is_viewing_jammer:
			property.jammer_manager.SetValidTargets()
			property.jammer_manager.Reset()
			if !intermediary.game_state.CheckIfJammerHasEligibleTargets(property):
				property.item_interaction.RevertJammer()
	if instance_property_array.size() == 1:
		intermediary.ExitGame(tr("MP_CONSOLE EXIT NOT ENOUGH PLAYERS"))
	print("globalparent visible: ", intermediary.globalparent_shotgun.visible)
	if !intermediary.globalparent_shotgun_main.visible:
		intermediary.SetShotgunVisible_Global(true)

func CheckToPassTurnAfterUserDisconnect(socket_number_that_disconnected : int):
	if GlobalSteam.STEAM_ID != GlobalSteam.HOST_ID: return
	if socket_number_that_disconnected == intermediary.game_state.MAIN_active_current_turn_socket:
		print("the active turn user has disconnected. passing turn to next user ...")
		await get_tree().create_timer(1, false).timeout
		round.MainRoutine_PassTurn(round.GetNextTurn_Socket(round.game_state.MAIN_active_current_turn_socket))

func PacketSort(dict : Dictionary):
	var value_category = dict.values()[0]
	var value_alias = dict.values()[1]
	
	match value_alias:
		"initial instance setup": 
			InitialInstanceSetup_Peer(dict)
		"exit to lobby":
			ExitGameWithLobby()

func GetRoot():
	var root_children = get_tree().root.get_children()
	for i in get_tree().root.get_children(): if i.name == "mp_main": scene_root = i

func StartMainGame():
	if (GlobalSteam.HOST_ID == GlobalSteam.STEAM_ID) or (GlobalVariables.mp_debugging): 
		if GlobalVariables.mp_debugging:
			GetEnvironmentalEvent()
			SetupDictionary_test()
			SetupInstances_test(instance_dictionary_test)
		else:
			InitialInstanceSetup_Host()
		print("waiting 2 seconds for initial instance setup ...")
		await get_tree().create_timer(2, false).timeout
		if intermediary.game_state.MAIN_active_environmental_event == "ice machine":
			intermediary.environmental_event.ShowIceMachine()
		round.MainRoutine_StartRound()
	else: print("failed to start initial instance setup. you are not assigned as the host.")

func InitialInstanceSetup_Host():
	print("initial instance setup with lobby array: ", GlobalSteam.LOBBY_MEMBERS) #debug here
	
	#main loop
	SetupDictionary()
	SetupInstances(instance_dictionary)
	var packet = {
		"packet category": "MP_UserInstanceHandler",
		"packet alias": "initial instance setup",
		"packet_id": 6,
		"instance_dict": instance_dictionary,
		"environmental_event": GetEnvironmentalEvent()
	}
	for member in GlobalSteam.LOBBY_MEMBERS: if member.steam_id != GlobalSteam.HOST_ID:
		packets.send_p2p_packet(member.steam_id, packet)

func InitialInstanceSetup_Peer(packet : Dictionary):
	var p = packet
	intermediary.game_state.MAIN_active_environmental_event = packet.environmental_event
	SetupInstances(p.instance_dict)

func SetupDictionary():
	var lobby_dict_array = GlobalSteam.LOBBY_MEMBERS
	lobby_dict_array.shuffle()
	var socket_index = 0
	var setting_opposite = lobby_dict_array.size() == 2
	for i in range(lobby_dict_array.size()):
		var is_host = lobby_dict_array[i].steam_id == GlobalSteam.HOST_ID
		if setting_opposite:
			if i == 0:
				socket_index = 1
			else:
				socket_index = 3
		var dict = {
			"socket_number": socket_index,
			"user_id": lobby_dict_array[i].steam_id,
			"is_host": is_host,
			"user_name": lobby_dict_array[i].steam_name,
			"cpu_enabled": false,
		}
		instance_dictionary.append(dict)
		socket_index += 1
	print("lobby dict array after initial dictionary array fill: ", lobby_dict_array)

func SetupInstances(dictionary_array):
	for user in dictionary_array:
		var setting_active = false
		var active_id = GlobalSteam.STEAM_ID
		if user.user_id == active_id: user.active_user_id = user.user_id; setting_active = true
		
		var _instance = user_instance.instantiate()
		var instance = _instance
		var properties = instance.get_child(0).get_child(0)
		
		properties.socket_number = user.socket_number
		properties.user_id = user.user_id
		properties.user_name = user.user_name
		properties.cpu_enabled = user.cpu_enabled
		properties.is_active = setting_active

		scene_root.add_child.call_deferred(instance)
		instance_property_array.append(properties)
		
		if (properties.is_active):
			#intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")
			intermediary.intermed_description = properties.description
			intermediary.intermed_properties = properties
		
		instance.rotation_degrees = socketArray_rotation[properties.socket_number]
		print("user dict after instance spawn: ", user)

func GetEnvironmentalEvent():
	var event_array = ["ice machine"]
	var roll = randi_range(0, 2000)
	var event = event_array.pick_random()
	print("environmental event roll: ", roll)
	if roll == 90: 
		intermediary.game_state.MAIN_active_environmental_event = event
		return event
	else:
		return ""

func SetupDictionary_test():
	var dict
	GlobalSteam.HOST_ID = 76561198358844980
	for i in range(4): 
		dict = {
			"socket_number": 0,
			"user_id": 0,
			"is_host" : false,
			"user_name": "",
			"cpu_enabled": false,
 		}
		instance_dictionary_test.append(dict)
	
	instance_dictionary_test[0].socket_number = 0
	instance_dictionary_test[0].user_id = 76561198358844980
	instance_dictionary_test[0].user_name = "MIKE"
	instance_dictionary_test[0].is_host = true
	
	instance_dictionary_test[1].socket_number = 1
	instance_dictionary_test[1].user_id = 111
	instance_dictionary_test[1].user_name = "RAM"
	instance_dictionary_test[1].cpu_enabled = true
	
	instance_dictionary_test[2].socket_number = 2
	instance_dictionary_test[2].user_id = 222
	instance_dictionary_test[2].user_name = "CROM"
	instance_dictionary_test[2].cpu_enabled = true
	
	instance_dictionary_test[3].socket_number = 3
	instance_dictionary_test[3].user_id = 333
	instance_dictionary_test[3].user_name = "BIT"
	instance_dictionary_test[3].cpu_enabled = true
	
	GlobalSteam.LOBBY_MEMBERS = [
	{	"steam_id": 76561198358844980,
		"steam_name": "Mike"},
	{ 	"steam_id": 111,
		"steam_name": "RAM"},
	{	"steam_id": 222,
		"steam_name": "CROM"},
	{ 	"steam_id": 333,
		"steam_name": "BIT"}
	]
	
	instance_dictionary_test.shuffle()
	previous_member_steamid_array = GlobalSteam.LOBBY_MEMBERS.duplicate()

func SetupInstances_test(dictionary_array):
	for user in dictionary_array:
		var setting_active = false
		var active_id = GlobalSteam.STEAM_ID
		if user.user_id == active_id:
			user.active_user_id = user.user_id
			setting_active = true
		print("user.user_id: ", user.user_id, " active id: ", active_id, " setting active: ", setting_active)
		
		var _instance = user_instance.instantiate()
		var instance = _instance
		var properties = instance.get_child(0).get_child(0)
		
		properties.socket_number = user.socket_number
		properties.user_id = user.user_id
		properties.user_name = user.user_name
		properties.cpu_enabled = user.cpu_enabled
		properties.is_active = setting_active

		scene_root.add_child.call_deferred(instance)
		instance_property_array.append(properties)
		
		if (properties.is_active): 
			intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")
			intermediary.intermed_description = properties.description
			intermediary.intermed_properties = properties
		
		instance.rotation_degrees = socketArray_rotation[properties.socket_number]
		print("user dict after instance spawn: ", user)
