class_name LobbyManager extends Node

enum lobby_status {Private, Friends, Public, Invisible}
enum search_distance {Close, Default, Far, Worldwide}

@export var is_menu : bool = false
@export var is_lobby : bool = false
@export var connecting_join_requested : bool = true
@export var connecting_lobby_chat_update : bool = true
@export var connecting_lobby_created : bool = true
@export var connecting_lobby_joined : bool = true
@export var connecting_persona_state_change : bool = true
@export var menu_manager : MenuManager
@export var command_line : MP_CommandLineChecker
@export var match_customization : MP_MatchCustomization
@export var matchmaking : MP_Matchmaking

@export var cursor : MP_CursorManager
@export var instance_handler : MP_UserInstanceHandler
@export var lobby_controller : LobbyController
@export var using_console : bool = false
@export var updating_list : bool = false
@export var pivot_points_to_update : Array[MP_ButtonClassMain]
@export var get_lobby_members_on_ready : bool
@export var checking_clipboard_ui : bool

@export var ui_copypaste_parent : Control
@export var ui_copypaste_console_pop : Label
@export var ui_copypaste_copy_lobby_id : Button
@export var ui_copypaste_join_with_id : Button
@export var ui_copypaste_icon_copy : TextureRect
@export var ui_copypaste_icon_paste : TextureRect
@export var animator_consolepop_copypaste_ui : AnimationPlayer

@export var lobby_ui : MP_LobbyUI

func _ready():
	AudioServer.set_bus_volume_db(3, linear_to_db(GlobalVariables.original_volume_linear_interaction))
	AudioServer.set_bus_volume_db(1, linear_to_db(GlobalVariables.original_volume_linear_music))
	
	if connecting_join_requested: Steam.join_requested.connect(_on_Lobby_Join_Requested)
	if connecting_lobby_chat_update: Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	if connecting_lobby_created: Steam.lobby_created.connect(_on_lobby_created)
	if connecting_lobby_joined: Steam.lobby_joined.connect(_on_lobby_joined)
	if connecting_persona_state_change: Steam.persona_state_change.connect(_on_persona_change)
	
	CheckCommandLine()
	ShowPopupWindowOnEnter()
	if get_lobby_members_on_ready: get_lobby_members()

var viewing_popup = false
func ShowPopupWindowOnEnter():
	await get_tree().create_timer(1.75, false).timeout
	print("showing popup window on enter with message to forward: ", GlobalVariables.message_to_forward)
	if is_lobby && GlobalVariables.message_to_forward != "":
		lobby_ui.ShowPopupWindow(GlobalVariables.message_to_forward)
		GlobalVariables.message_to_forward = ""

func ShowForwardedMessage():
	if GlobalVariables.message_to_forward != "":
		Console(GlobalVariables.message_to_forward)
		GlobalVariables.message_to_forward = ""

var interaction_enabled = true
func Pipe(alias : String = "", sub_alias : String = ""):
	match alias:
		"create lobby":
			CreateLobby()
		"leave lobby":
			leave_lobby()
		"start game":
			lobby_controller.StartGame()
		"language japanese":
			TranslationServer.set_locale("JA")
		"language chinese":
			TranslationServer.set_locale("ZHS")
		"language english":
			TranslationServer.set_locale("EN")
		"join with lobby id":
			JoinLobbyWithPastedID()
		"copy lobby id":
			CopyLobbyID()
		"invite friends":
			ShowInviteDialogue()
		"return to main menu":
			lobby_ui.ExitToMainMenu()
		"kick player in lobby":
			KickPlayerInLobby(int(sub_alias))
		"close popup":
			lobby_ui.ClosePopupWindow()
		"find players to play with":
			lobby_ui.OpenDiscordLink()
		"customize match settings":
			lobby_ui.EnterMatchCustomization()
		"search for lobbies":
			lobby_ui.EnterLobbySearch()
		"friends only toggle":
			ToggleLobbyFriendsOnly()
		"player limit toggle":
			TogglePlayerLimit()
		"exit lobby search":
			lobby_ui.ExitLobbySearch()
		"toggle search range":
			matchmaking.ToggleSearchRange()
		"refresh search list":
			matchmaking.RefreshList()
		"lobby result join":
			matchmaking.JoinLobbyFromSearch(int(sub_alias))

func KickPlayerInLobby(steam_id : int):
	print("attempting to kick player: ", steam_id)
	if GlobalSteam.STEAM_ID != GlobalSteam.HOST_ID: return
	var packet = {
		"packet category": "MP_LobbyManager",
		"packet alias": "kick player",
		"sent_from": "host",
		"packet_id": 26,
		"steam_id": steam_id,
	}
	packets.send_p2p_packet(0, packet)
	if GlobalVariables.mp_debugging: packets.PipeData(packet)

func ShowInviteDialogue():
	if GlobalSteam.LOBBY_ID == 0: return
	Steam.activateGameOverlayInviteDialog(GlobalSteam.LOBBY_ID)

func JoinLobbyWithPastedID():
	var current_clipboard = DisplayServer.clipboard_get()
	if current_clipboard.length() != 18:
		Console_Copypaste(tr("MP_UI LOBBY ID ERROR INVALID CLIPBOARD"))
		return
	leave_lobby()
	join_lobby(int(current_clipboard))

func CopyLobbyID():
	DisplayServer.clipboard_set(str(GlobalSteam.LOBBY_ID))
	Console_Copypaste(tr("MP_UI LOBBY ID MESSAGE COPIED"))

func Console_Copypaste(message : String):
	print("printing message to player visible console: ", message)
	ui_copypaste_console_pop.text = message
	animator_consolepop_copypaste_ui.play("RESET")
	animator_consolepop_copypaste_ui.play("pop")

func ToggleLobbyFriendsOnly():
	if GlobalSteam.LOBBY_ID != 0 && GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
		GlobalSteam.is_lobby_friends_only = !GlobalSteam.is_lobby_friends_only
		if GlobalSteam.is_lobby_friends_only:
			Steam.setLobbyType(GlobalSteam.LOBBY_ID, Steam.LOBBY_TYPE_FRIENDS_ONLY)
			Console_Copypaste(tr("MP_LOBBY SET PRIVATE"))
		else:
			Steam.setLobbyType(GlobalSteam.LOBBY_ID, Steam.LOBBY_TYPE_PUBLIC)
			Console_Copypaste(tr("MP_LOBBY SET PUBLIC"))

func TogglePlayerLimit():
	if GlobalSteam.LOBBY_ID != 0 && GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
		if GlobalSteam.lobby_player_limit == 4:
			GlobalSteam.lobby_player_limit = 2
		else:
			GlobalSteam.lobby_player_limit += 1
		Steam.setLobbyData(GlobalSteam.LOBBY_ID, "player_limit", str(GlobalSteam.lobby_player_limit))
		Steam.setLobbyMemberLimit(GlobalSteam.LOBBY_ID, GlobalSteam.lobby_player_limit)

func CreateLobby():
	print("attempting to create lobby")
	if (GlobalSteam.LOBBY_ID == 0):
		GlobalSteam.is_lobby_friends_only = true
		GlobalSteam.lobby_player_limit = 4
		Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, GlobalSteam.lobby_player_limit)
		Steam.setLobbyData(GlobalSteam.LOBBY_ID, "player_limit", str(GlobalSteam.lobby_player_limit))

func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect == 1:
		GlobalSteam.is_lobby_friends_only = true
		# Set the lobby ID
		GlobalSteam.LOBBY_ID = this_lobby_id
		GlobalVariables.steam_id_version_checked_array.append(GlobalSteam.STEAM_ID)
		print("Created a lobby: %s" % GlobalSteam.LOBBY_ID)

		# Set this lobby as joinable, just in case, though this should be done by default
		Steam.setLobbyJoinable(GlobalSteam.LOBBY_ID, true)

		# Allow P2P connections to fallback to being relayed through Steam if needed
		var set_relay: bool = Steam.allowP2PPacketRelay(true)
		print("Allowing Steam to be relay backup: %s" % set_relay)
	if GlobalVariables.sending_lobby_change_alerts_to_console: Console("created lobby with connection: " + str(connect) + " and id: " + str(this_lobby_id))
	if GlobalVariables.controllerEnabled:
		lobby_ui.GetFirstUIFocus()

func _on_Lobby_Join_Requested(this_lobby_id: int, friend_id: int) -> void:
	# Get the lobby owner's name
	var owner_name: String = Steam.getFriendPersonaName(friend_id)
	
	print("Joining %s's lobby..." % owner_name)
	
	# Attempt to join the lobby
	join_lobby(this_lobby_id)

func join_lobby(this_lobby_id: int) -> void:
	leave_lobby()
	print("Attempting to join lobby %s" % this_lobby_id)
	
	if is_menu:
		print("user joined lobby in menu. force change scene to lobby before joining")
		menu_manager.DisableMenu()
		command_line.JoinGameOutsideLobby(this_lobby_id)
		return
	
	# Clear any previous lobby members lists, if you were in a previous lobby
	GlobalSteam.LOBBY_MEMBERS.clear()
	
	# Make the lobby join request to Steam
	Steam.joinLobby(this_lobby_id)

func leave_lobby() -> void:
	GlobalSteam.is_lobby_friends_only = true
	GlobalSteam.lobby_player_limit = 4
	GlobalVariables.previous_match_customization_differences = {}
	GlobalVariables.lobby_id_found_in_command_line = 0
	# If in a lobby, leave it
	if GlobalSteam.LOBBY_ID != 0:
		# Send leave request to Steam
		Steam.leaveLobby(GlobalSteam.LOBBY_ID)
		
		# Wipe the Steam lobby ID then display the default lobby ID and player list title
		GlobalSteam.LOBBY_ID = 0
		GlobalVariables.steam_id_version_checked_array = []
		print("### lobby members: ", GlobalSteam.LOBBY_MEMBERS)
		# Close session with all users
		for this_member in GlobalSteam.LOBBY_MEMBERS:
			# Make sure this isn't your Steam ID
			if this_member['steam_id'] != GlobalSteam.STEAM_ID:
				
				# Close the P2P session
				print("closing p2p sesion with user")
				Steam.closeP2PSessionWithUser(this_member['steam_id'])
				
		# Clear the local lobby list
		GlobalSteam.LOBBY_MEMBERS.clear()
		GlobalSteam.USER_ID_LIST_TO_IGNORE.clear()
		if lobby_ui != null: 
			lobby_ui.UpdatePlayerList()
		GlobalSteam.HOST_ID = 0
		get_lobby_members()
	if GlobalVariables.sending_lobby_change_alerts_to_console: Console("left lobby with new members and id: " + str(GlobalSteam.LOBBY_MEMBERS) + str(GlobalSteam.LOBBY_MEMBERS))
	if lobby_ui != null:
		if cursor != null && cursor.controller_active:
			lobby_ui.GetFirstUIFocus().grab_focus()
		if cursor != null && cursor.controller != null:
			cursor.controller.previousFocus = lobby_ui.GetFirstUIFocus()
	if match_customization != null:
		match_customization.ClearMatchCustomizationUI()

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	GlobalVariables.lobby_id_found_in_command_line = 0
	# If joining was successful
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		
		GlobalSteam.LOBBY_ID = this_lobby_id
		
		get_lobby_members()
		make_p2p_handshake()
		check_version()
	# Else it failed for some reason
	else:
		# Get the failure reason
		var fail_reason: String
		var p_fail_reason : String
		
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: p_fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: p_fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: p_fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: p_fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: p_fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: p_fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: p_fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: p_fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: p_fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: p_fail_reason = "A user you have blocked is in the lobby."
		
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = tr("MP_UI LOBBY ID ERROR DISBANDED")
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = tr("MP_UI LOBBY FULL")
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = tr("MP_UI LOBBY LIMITED")
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = tr("MP_UI LOBBY BLOCKED YOU")
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = tr("MP_UI LOBBY BLOCKED MEMBER")
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = tr("#MP_ERROR GAME STARTED")
			_: fail_reason = tr("MP_UI LOBBY FAIL GENERIC")
		
		print("Failed to join this chat room: %s" % p_fail_reason)
		lobby_ui.ShowPopupWindow(fail_reason)
		
		#Reopen the lobby list
		#_on_open_lobby_list_pressed()
	if GlobalVariables.sending_lobby_change_alerts_to_console: Console("joined lobby: " + str(this_lobby_id) + " with response: " + str(response))
	if lobby_ui != null:
		if cursor != null && cursor.controller_active:
			lobby_ui.GetFirstUIFocus().grab_focus()
		if cursor != null && cursor.controller != null:
			cursor.controller.previousFocus = lobby_ui.GetFirstUIFocus()

@export var packets : PacketManager
func make_p2p_handshake() -> void:
	packets.make_p2p_handshake()
	#print("Sending P2P handshake to the lobby")
	#send_p2p_packet(0, {"message": "handshake", "from": GlobalSteam.STEAM_ID})

func check_version():
	if GlobalSteam.STEAM_ID != GlobalSteam.HOST_ID:
		print("sending host the current version (%s) and waiting for response." % GlobalVariables.version_to_check)
		var packet = {
			"packet category": "MP_LobbyManager",
			"packet alias": "check version",
			"sent_from": "client",
			"packet_id": 32,
			"version": GlobalVariables.version_to_check,
		}
		packets.send_p2p_packet_directly_to_host(GlobalSteam.STEAM_ID, packet)

func _on_lobby_chat_update(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	# Get the user who has made the lobby change
	var changer_name: String = Steam.getFriendPersonaName(change_id)
	
	# If a player has joined the lobby
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		print("%s has joined the lobby." % changer_name)
	
	# Else if a player has left the lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		GlobalVariables.steam_id_version_checked_array.erase(change_id)
		print("%s has left the lobby." % changer_name)
	
	# Else if a player has been kicked
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		GlobalVariables.steam_id_version_checked_array.erase(change_id)
		print("%s has been kicked from the lobby." % changer_name)
	
	# Else if a player has been banned
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		GlobalVariables.steam_id_version_checked_array.erase(change_id)
		print("%s has been banned from the lobby." % changer_name)
	
	# Else there was some unknown change
	else:
		print("%s did... something." % changer_name)
	
	# Update the lobby now that a change has occurred
	get_lobby_members()

var previous_host = 0
func get_lobby_members() -> void:
	var temp_hostname = ""
	var temp_hostid = 0
	
	if instance_handler != null:
		instance_handler.previous_member_steamid_array = GlobalSteam.LOBBY_MEMBERS.duplicate()
	
	#print("member array before clear: ", GlobalSteam.LOBBY_MEMBERS)
	# Clear your previous lobby list
	GlobalSteam.LOBBY_MEMBERS.clear()
	
	# Get the number of members from this lobby from Steam
	var num_of_members: int = Steam.getNumLobbyMembers(GlobalSteam.LOBBY_ID)
	
	# Get the data of these players from Steam
	for this_member in range(0, num_of_members):
		# Get the member's Steam ID
		var member_steam_id: int = Steam.getLobbyMemberByIndex(GlobalSteam.LOBBY_ID, this_member)
		# Get the member's Steam name
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)
		# Add them to the list
		GlobalSteam.LOBBY_MEMBERS.append({"steam_id":member_steam_id, "steam_name":member_steam_name})
	if lobby_ui != null: 
		lobby_ui.UpdatePlayerList()
	if instance_handler != null: instance_handler.current_member_steamid_array = GlobalSteam.LOBBY_MEMBERS.duplicate()
	GlobalSteam.HOST_ID = Steam.getLobbyOwner(GlobalSteam.LOBBY_ID)
	
	if GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
		Steam.setLobbyData(GlobalSteam.LOBBY_ID, "member_count", str(GlobalSteam.LOBBY_MEMBERS.size()))
		if !(GlobalSteam.HOST_ID in GlobalVariables.steam_id_version_checked_array):
			GlobalVariables.steam_id_version_checked_ayeahrray.append(GlobalSteam.HOST_ID)

	if (previous_host != GlobalSteam.HOST_ID) && (GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID):
		if match_customization != null:
			GlobalSteam.lobby_player_limit = 4
			Steam.setLobbyMemberLimit(GlobalSteam.LOBBY_ID, GlobalSteam.lobby_player_limit)
			Steam.setLobbyData(GlobalSteam.LOBBY_ID, "player_limit", str(GlobalSteam.lobby_player_limit))
		if match_customization != null:
			match_customization.CheckMatchCustomizationDifferences()
	previous_host = GlobalSteam.HOST_ID
	var temp_string
	if (GlobalSteam.STEAM_ID == Steam.getLobbyOwner(GlobalSteam.LOBBY_ID)): 
		temp_string = "you are the host."
	else: 
		temp_string = "you are not the host."
	#if GlobalVariables.sending_lobby_change_alerts_to_console: print("updating lobby member array with lobby member array: ", GlobalSteam.LOBBY_MEMBERS)
	#if GlobalVariables.sending_lobby_change_alerts_to_console: Console("updating lobby member array:\n \n" +  str(GlobalSteam.LOBBY_MEMBERS) + " in id: " + str(GlobalSteam.LOBBY_ID) + "\n" + "\n" + temp_string)
	if instance_handler != null: instance_handler.CheckLobbyMemberArray()
	if lobby_ui != null: 
		lobby_ui.UpdatePlayerList()

func _on_persona_change(this_steam_id: int, _flag: int) -> void:
	# Make sure you're in a lobby and this user is valid or Steam might spam your console log
	if GlobalSteam.LOBBY_ID > 0:
		if GlobalVariables.sending_lobby_change_alerts_to_console: print("A user (%s) had information change, update the lobby list" % this_steam_id)
		
		# Update the player list
		get_lobby_members()

func ReceivePacket_KickPlayer(packet : Dictionary):
	print("kicking with packet: ", packet)
	print("self id: ", GlobalSteam.STEAM_ID, " id to kick in packet: ", packet.steam_id)
	GlobalSteam.USER_ID_LIST_TO_IGNORE.append(packet.steam_id)
	if GlobalSteam.STEAM_ID == packet.steam_id:
		leave_lobby()
		if is_lobby:
			lobby_ui.ShowPopupWindow(tr("MP_UI LOBBY KICKED"))
		if instance_handler != null: 
			instance_handler.intermediary.ExitGame(tr("MP_UI LOBBY KICKED"))
	if GlobalVariables.mp_debugging:
		for i in range(GlobalSteam.LOBBY_MEMBERS.size()):
			if GlobalSteam.LOBBY_MEMBERS[i].steam_id == packet.steam_id:
				GlobalSteam.LOBBY_MEMBERS.remove_at(i)
				break
		instance_handler.CheckLobbyMemberArray()

func ReceivePacket_VersionCheck(packet : Dictionary, user_id : int):
	if GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
		var allowed = GlobalVariables.version_to_check == packet.version
		if allowed:
			print("version check with %s successful." % user_id)
			GlobalVariables.steam_id_version_checked_array.append(user_id)
			lobby_ui.CheckAllVersions()
		else:
			print("version check with %s unsuccessful." % user_id)
			Console_Copypaste(tr("MP_UI LOBBY VERSION MISMATCH HOST") % Steam.getFriendPersonaName(user_id))
		var response = {
			"packet category": "MP_LobbyManager",
			"packet alias": "version response",
			"sent_from": "host",
			"packet_id": 33,
			"entry_allowed": allowed,
			"host_version": GlobalVariables.version_to_check,
		}
		packets.send_p2p_packet(user_id, response)
		if allowed:
			match_customization.CheckMatchCustomizationDifferences()

func ReceivePacket_VersionResponse(packet : Dictionary):
	if !packet.entry_allowed:
		print("this version of the game: (%s) did not match the host version: (%s). disconnecting." % [GlobalVariables.version_to_check, packet.host_version])
		lobby_ui.ShowPopupWindow(tr("MP_UI LOBBY VERSION MISMATCH") % [GlobalVariables.version_to_check, packet.host_version])
		leave_lobby()
	else:
		print("this version of the game: (%s) matches the host version: (%s). continuing." % [GlobalVariables.version_to_check, packet.host_version])

@export var ui_memberlist : Label
@export var ui_id_user : Label
@export var ui_id_host : Label
@export var ui_id_table : Label
func UpdateList():
	if (updating_list):
		var t = ""
		var temp_memberlist = GlobalSteam.LOBBY_MEMBERS.duplicate()
		for member in temp_memberlist: 
			t += member["steam_name"] + "\n"
		print(t)
		if (t == null): t = ""
		ui_memberlist.text = t

@export var pop_anim : AnimationPlayer
@export var pop_ui : Label
@export var pop_sp : AudioStreamPlayer2D
func Console(message : String):
	return
	if (using_console):
		pop_sp.pitch_scale = randf_range(2, 2)
		pop_sp.stop()
		pop_sp.play()
		pop_ui.text = str(message)
		pop_anim.play("RESET")
		pop_anim.play("pop")

func CheckCommandLine():
	var arguments = OS.get_cmdline_args()
	for argument in arguments:
		if (arguments.size() > 0):
			#if (GlobalSteam.LOBBY_INVITE_ARG):
			#	join_lobby(int(argument))
			pass
	
		if argument == "+connect_lobby":
			GlobalSteam.LOBBY_INVITE_ARG = true
