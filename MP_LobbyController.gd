class_name LobbyController extends Node

@export var cursor : MP_CursorManager
@export var packets : PacketManager
@export var anim_start : AnimationPlayer
@export var lobby_manager : LobbyManager
@export var lobby_ui : MP_LobbyUI
var lobby_initialized

func _unhandled_input(event):
	if event.is_action_pressed("1") && GlobalVariables.mp_debugging:
		print("starting game with match customization settings: ", GlobalVariables.active_match_customization_dictionary)
		StartGameRoutine_Host()

var fs = false
func StartGame():
	if (!fs):
		if (GlobalSteam.LOBBY_ID != 0):
			if (GlobalSteam.LOBBY_MEMBERS.size() > 1):
				if (GlobalSteam.HOST_ID == GlobalSteam.STEAM_ID):
					print("starting game with match customization settings: ", GlobalVariables.active_match_customization_dictionary)
					Steam.setLobbyJoinable(GlobalSteam.LOBBY_ID, false)
					StartGameRoutine_Host()
					fs = true
					return
				else:
					print("failed to start game. you are not the host."); return
			else:
				lobby_manager.Console_Copypaste(tr("MP_UI LOBBY MESSAGE NOT ENOUGH"))
				print("failed to start game. not enough players."); return
		print("failed to start game. lobby does not exist")

func StartGameRoutine_Host():
	var packet = {
		"packet category": "lobby",
		"packet alias": "start game from lobby",
		"packet_id": 2,
	}
	packets.send_p2p_packet(0, packet)
	StartGameRoutine_Main()
	await get_tree().create_timer(3.8, false).timeout
	StartGameRoutine_LoadScene()

func StartGameRoutine_Main():
	lobby_ui.SetupMainSceneLoad()

func StartGameRoutine_LoadScene():
	get_tree().change_scene_to_file("res://multiplayer/scenes/mp_main.tscn")
