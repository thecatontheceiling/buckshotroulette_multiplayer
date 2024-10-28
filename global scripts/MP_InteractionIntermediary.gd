class_name MP_InteractionIntermed extends Node

var current_turn_holder_socket = 5
var intermed_activeParent
var intermed_uiArray = ["", ""]
var intermed_description
var intermed_properties : MP_UserInstanceProperties

@export var speaker_button_press : AudioStreamPlayer2D
@export var speaker_button_hover : AudioStreamPlayer2D
@export var item_spawn_global_parent : Node3D
@export var game_state : MP_GameStateManager
@export var instance_handler : MP_UserInstanceHandler
@export var globalparent_shotgun_main : Node3D
@export var globalparent_shotgun_forestock : Node3D
@export var globalparent_shotgun_window : Node3D
@export var globalparent_shotgun : Node3D
@export var globalparent_shotgun_cut_segment : Node3D
@export var globalparent_shotgun_cut_segment_mesh : Node3D
@export var globalanimator_cut_segment : AnimationPlayer
@export var intbranch_shotgun : MP_InteractionBranch
@export var animator_globalcenterlight : AnimationPlayer
@export var packets : PacketManager
@export var roundManager : MP_RoundManager
@export var post_processing : WorldEnvironment
@export var win_manager : MP_WinManager
@export var anim_pp_muzzle_flash : AnimationPlayer
@export var anim_pp_revive : AnimationPlayer
@export var light_center : Light3D
@export var light_center_controller : MP_LightController
@export var editor_debug : MP_EditorDebug
@export var ingame_lobby_ui : MP_IngameLobbyUI
@export var input_blocker : Control
@export var viewblocker_top_global : Control
@export var music_manager : MP_MusicManager
@export var filter : MP_FilterController
@export var environmental_event : MP_EnvironmentalEvent

func _ready():
	viewblocker_top_global.visible = false
	input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE

func HoverPanEntered(active_hoverpan_socket : int):
	#print("hover pan function with: ", active_hoverpan_socket)
	pass

func SetShotgunVisible_Global(setting_visible : bool):
	globalparent_shotgun_main.visible = setting_visible
	globalparent_shotgun_forestock.visible = setting_visible

func ExitGame(message_to_forward : String = ""):
	instance_handler.removing_instances = false
	print("exiting game with message to forward: ", message_to_forward)
	GlobalVariables.message_to_forward = message_to_forward
	input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	viewblocker_top_global.visible = true
	ingame_lobby_ui.toggle_allowed = false
	await get_tree().create_timer(.3, false).timeout
	print("global variables disband lobby after exiting main scene: ", GlobalVariables.disband_lobby_after_exiting_main_scene)
	if !GlobalVariables.mp_debugging && GlobalVariables.disband_lobby_after_exiting_main_scene: 
		print("exiting game and disbanding current lobby.")
		ingame_lobby_ui.lobby.leave_lobby()
	GlobalVariables.running_short_intro_in_lobby_scene = true
	GlobalVariables.disband_lobby_after_exiting_main_scene = false
	get_tree().change_scene_to_file("res://multiplayer/scenes/mp_lobby.tscn")

func InteractionPipe(alias : String, button_class_main : MP_ButtonClassMain):
	match alias:
		"disconnect button":
			ingame_lobby_ui.ShowConfirmation()
		"disconnect confirmation yes":
			if GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
				GlobalVariables.disband_lobby_after_exiting_main_scene = true
				ExitGame()
				#instance_handler.Setup_ExitGameWithLobbyMembers()
			else:
				GlobalVariables.disband_lobby_after_exiting_main_scene = true
				ExitGame()
		"disconnect confirmation no":
			ingame_lobby_ui.HideConfirmation()
		"continue button":
			ingame_lobby_ui.ToggleUI()
		"kick button":
			var packet = {
				"packet category": "MP_LobbyManager",
				"packet alias": "kick player",
				"sent_from": "host",
				"packet_id": 26,
				"steam_id": button_class_main.segment.user_id,
			}
			packets.send_p2p_packet(0, packet)
			if GlobalVariables.mp_debugging: packets.PipeData(packet)

































