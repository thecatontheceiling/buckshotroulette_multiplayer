class_name PacketManager extends Node

@export var lobby_ui : MP_LobbyUI
@export_group("mp_main")
@export var game_state : MP_GameStateManager
@export var lobby : LobbyManager
@export var instance_handler : MP_UserInstanceHandler
@export var round_manager : MP_RoundManager
@export var verifier : MP_PacketVerification
@export_group("")

func _ready() -> void:
	Steam.p2p_session_request.connect(_on_p2p_session_request)
	Steam.p2p_session_connect_fail.connect(_on_p2p_session_connect_fail)

func GetTime():
	return str(Time.get_time_string_from_system())

func _process(_delta) -> void:
	# If the player is connected, read packets
	if GlobalSteam.LOBBY_ID > 0:
		read_p2p_packet()

var read_count
func read_all_p2p_packets(read_count: int = 0):
	if read_count >= GlobalSteam.PACKET_READ_LIMIT:
		return
	
	if Steam.getAvailableP2PPacketSize(0) > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)

func send_p2p_packet_directly_to_host(sending_from_id : int, packet_data : Dictionary):
	if sending_from_id == GlobalSteam.HOST_ID && !GlobalVariables.mp_debugging:
		var verified_packet = verifier.VerifyPacket(packet_data)
		PipeData(verified_packet)
	else:
		send_p2p_packet(GlobalSteam.HOST_ID, packet_data)

func send_p2p_packet_through_host(sending_From_id : int, packet_data : Dictionary):
	print("checking if sending packet through host with packet data: ", packet_data)
	if sending_From_id == GlobalSteam.HOST_ID:
		print("packet is already sending from host. sending to all members.")
		packet_data.confirmed = true
		send_p2p_packet(0, packet_data)
	else:
		print("packet is not from host. sending through host.")
		packet_data.confirmed = false
		send_p2p_packet(GlobalSteam.HOST_ID, packet_data)

func send_p2p_packet(target: int, packet_data: Dictionary) -> void:
	if GlobalVariables.mp_debugging: return
	# Set the send_type and channel
	var send_type: int = Steam.P2P_SEND_RELIABLE
	var channel: int = 0
	
	# Create a data array to send the data through
	var this_data: PackedByteArray
	
	# Compress the PackedByteArray we create from our dictionary  using the GZIP compression method
	var compressed_data: PackedByteArray = var_to_bytes(packet_data).compress(FileAccess.COMPRESSION_GZIP)
	this_data.append_array(compressed_data)
	
	# If sending a packet to everyone
	if target == 0:
		# If there is one or more users, send packets
		if GlobalSteam.LOBBY_MEMBERS.size() >= 1:
			# Loop through all members that aren't you
			for this_member in GlobalSteam.LOBBY_MEMBERS:
				if this_member['steam_id'] != GlobalSteam.STEAM_ID:
					Steam.sendP2PPacket(this_member['steam_id'], this_data, send_type, channel)
					if GlobalVariables.printing_packets: print("sending packet with target 0: ", packet_data)

	# Else send it to someone specific
	else:
		Steam.sendP2PPacket(target, this_data, send_type, channel)

func read_p2p_packet() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)
	
	# There is a packet
	if packet_size > 0:
		var this_packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		
		if this_packet.is_empty() or this_packet == null:
			print("WARNING: read an empty packet with non-zero size!")
		
		# Get the remote user's ID
		var packet_sender: int = this_packet['steam_id_remote']
		
		# Make the packet data readable
		var packet_code: PackedByteArray = this_packet['data']
		var readable_data: Dictionary = bytes_to_var(packet_code.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
		
		if GlobalSteam.STEAM_ID != GlobalSteam.HOST_ID:
			if packet_sender != GlobalSteam.HOST_ID: 
				print("packet refused: received packet from non-host user.")
				return
		
		if packet_sender in GlobalSteam.USER_ID_LIST_TO_IGNORE:
			print("packet refused: received packet from an ID that is set to be ignored.")
			return
		
		if game_state != null:
			if packet_sender in game_state.MAIN_active_user_id_to_ignore_timeout_packets_array:
				print("received packet from an ID that has exceeded timeout")
				if readable_data.packet_id in game_state.MAIN_active_timeout_packet_id_array:
					print("received packet is set to ignore on timeout. refused")
				else:
					print("received packet is not set to ignore on timeout. continuing")
		
		if packet_sender == GlobalSteam.HOST_ID:
			print("received packet from host")
		if GlobalVariables.printing_packets: 
			print("received packet: ", readable_data)
		
		PipeData(readable_data)

@export var lobbyController : LobbyController
@export var memberChecker : MemberChecker
func PipeData(dict : Dictionary):
	if GlobalVariables.printing_packets: print("[", GetTime(), "]", ": sorting packet: ", dict)
	var value_category = dict.values()[0]
	var value_alias = dict.values()[1]
	match value_category:
		"MP_UserInstanceHandler": 
			instance_handler.PacketSort(dict)
		"MP_RoundManager":
			round_manager.PacketSort(dict)
		"MP_UserInstanceProperties":
			for instance in instance_handler.instance_property_array:
				instance.PacketSort(dict)
		"MP_PacketVerification":
			verifier.VerifyPacket(dict)
			verifier.PacketSort(dict)
	match value_alias:
		"handshake":
			print("got handshake with dictionary: ", dict)
		"start game from lobby":
			lobbyController.StartGameRoutine_Main()
		"host arrived in main scene":
			lobbyController.StartGameRoutine_LoadScene()
		"member joined list":
			var steam_id = dict["steam_id"]
			memberChecker.MemberJoinedList(steam_id)
		"update member list":
			var temp_numberOfPlayersHere = dict["number of players here"]
			memberChecker.amountOfPlayers_here = temp_numberOfPlayersHere	
			memberChecker.UpdateMemberList()
		"all members arrived":
			memberChecker.MembersArrived()
		"kick player":
			lobby.ReceivePacket_KickPlayer(dict)
		"update match info ui":
			lobby_ui.UpdateMatchInformation(dict)

func _on_p2p_session_request(remote_id: int) -> void:
	# Get the requester's name
	var this_requester: String = Steam.getFriendPersonaName(remote_id)
	print("%s is requesting a P2P session" % this_requester)
	
	# Accept the P2P session; can apply logic to deny this request if needed
	Steam.acceptP2PSessionWithUser(remote_id)
	
	# Make the initial handshake
	make_p2p_handshake()

func make_p2p_handshake() -> void:
	print("Sending P2P handshake to the lobby in packet manager")
	
	#temp steam id for lobby of 1 member: 76561198358844980 Mike
	#set to 0 for handshake with rest of lobby
	var packet = {
		"packet category": "lobby",
		"packet alias": "handshake",
		"packet_id": 1,
		"message": str("handshake from: " , GlobalSteam.STEAM_ID)
	}
	send_p2p_packet(0, packet)

func _on_p2p_session_connect_fail(steam_id: int, session_error: int) -> void:
	# If no error was given
	if session_error == 0:
		print("WARNING: Session failure with %s: no error given" % steam_id)
	
	# Else if target user was not running the same game
	elif session_error == 1:
		print("WARNING: Session failure with %s: target user not running the same game" % steam_id)
	
	# Else if local user doesn't own app / game
	elif session_error == 2:
		print("WARNING: Session failure with %s: local user doesn't own app / game" % steam_id)
	
	# Else if target user isn't connected to Steam
	elif session_error == 3:
		print("WARNING: Session failure with %s: target user isn't connected to Steam" % steam_id)
	
	# Else if connection timed out
	elif session_error == 4:
		print("WARNING: Session failure with %s: connection timed out" % steam_id)
	
	# Else if unused
	elif session_error == 5:
		print("WARNING: Session failure with %s: unused" % steam_id)
	
	# Else no known error
	else:
		print("WARNING: Session failure with %s: unknown error %s" % [steam_id, session_error])
