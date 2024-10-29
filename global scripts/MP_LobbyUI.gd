class_name MP_LobbyUI extends Node

@export var packets : PacketManager
@export var cursor : MP_CursorManager
@export var lobby : LobbyManager
@export var ui_host : Array[Control]
@export var ui_member : Array[Control]

@export var ui_button_host : Control
@export var ui_button_leave : Control
@export var ui_button_start_game : Control
@export var ui_copy_id : Control
@export var ui_join_with_id : Control
@export var ui_invite_friends : Control
@export var ui_skip_intro : Control
@export var ui_skip_intro_checkbox : Control
@export var ui_customize_match_settings : Control
@export var ui_number_of_rounds : Label
@export var ui_checkbox_number_of_rounds_plus : Control
@export var ui_checkbox_number_of_rounds_minus : Control
@export var ui_checkbox_button_skip_intro : Button
@export var ui_check_skip_intro : Control

@export var button_class_host : Control
@export var button_class_leave : Control

@export var pos_number_of_rounds_client : Vector2
@export var pos_number_of_rounds_host : Vector2

@export var array_members : Array[Label]
@export var array_kick : Array[Control]
@export var array_circles : Array[Control]

@export var animator_intro : AnimationPlayer
@export var speaker_music : AudioStreamPlayer2D
@export var speaker_intro : AudioStreamPlayer2D
@export var speaker_info_change : AudioStreamPlayer2D
@export var speaker_enter_main : AudioStreamPlayer2D
@export var speaker_exit : AudioStreamPlayer2D
@export var viewblocker_main : Control
@export var animator_game_start : AnimationPlayer

func _ready():
	cursor.SetCursor(false, false)
	UpdatePlayerList()
	UpdateMatchInformation()
	
	if GlobalVariables.running_short_intro_in_lobby_scene:
		ShortIntro()
	else:
		LongIntro()
	GlobalVariables.running_short_intro_in_lobby_scene = false
	SetWidth()

func GetFirstUIFocus():
	var first_focus : Control
	if GlobalSteam.LOBBY_ID == 0:
		first_focus = button_class_host
		print("first focus: host")
	else:
		first_focus = button_class_leave
		print("first focus: leave")
	return first_focus

func ShortIntro():
	await get_tree().create_timer(.1, false).timeout
	animator_intro.play("short intro")
	speaker_music.play()
	await get_tree().create_timer(2.5, false).timeout
	cursor.SetCursor(true, true)
	if GlobalVariables.controllerEnabled:
		GetFirstUIFocus().grab_focus()
	cursor.controller.previousFocus = GetFirstUIFocus()
	await get_tree().create_timer(.3, false).timeout
	if GlobalVariables.lobby_id_found_in_command_line != 0:
		lobby.join_lobby(GlobalVariables.lobby_id_found_in_command_line)

func LongIntro():
	await get_tree().create_timer(.1, false).timeout
	animator_intro.play("intro1")
	speaker_music.play()
	speaker_intro.play()
	await get_tree().create_timer(7, false).timeout
	cursor.SetCursor(true, true)
	if GlobalVariables.controllerEnabled:
		GetFirstUIFocus().grab_focus()
	cursor.controller.previousFocus = GetFirstUIFocus()

func _process(delta):
	CheckHostLeave()
	CheckLobbyCopyPaste()
	CheckHostUI()
	CheckStartButton()

var prev_members = []
var fs = false
var playing_info_change_sound = true
func UpdatePlayerList():
	var members = GlobalSteam.LOBBY_MEMBERS.duplicate()
	if members.size() != prev_members.size() && fs:
		speaker_info_change.pitch_scale = randf_range(0.2, .3)
		if playing_info_change_sound: speaker_info_change.play()
	prev_members = members
	for i in range(array_members.size()):
		array_members[i].text = ""
		array_kick[i].visible = false
		array_circles[i].visible = false
	for i in range(members.size()):
		array_members[i].text = GlobalSteam.LOBBY_MEMBERS[i]["steam_name"]
		array_circles[i].visible = true
		if i != 0 && GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID: 
			array_kick[i].visible = true
			array_kick[i].get_child(0).get_child(0).sub_alias = str(members[i].steam_id)
	fs = true

func SetWidth():
	var x = 94
	match TranslationServer.get_locale():
		"TR":
			x = 111
		"EE":
			x = 126
		"EN":
			x = 94
		"RU":
			x = 104
	for k in array_kick:
		k.size = Vector2(x, k.size.y)

func ToggleSkipIntro():
	GlobalVariables.skipping_intro = !GlobalVariables.skipping_intro
	SendMatchInformation()

func NumberOfRounds_Add():
	if GlobalVariables.debug_round_index_to_end_game_at == 2: return
	GlobalVariables.debug_round_index_to_end_game_at += 1
	SendMatchInformation()

func NumberOfRounds_Subtract():
	if GlobalVariables.debug_round_index_to_end_game_at == 0: return
	GlobalVariables.debug_round_index_to_end_game_at -= 1
	SendMatchInformation()

func SendMatchInformation():
	var packet = {
		"packet category": "MP_LobbyManager",
		"packet alias": "update match info ui",
		"sent_from": "host",
		"packet_id": 29,
		"number_of_rounds": GlobalVariables.debug_round_index_to_end_game_at + 1,
		"skipping_intro": GlobalVariables.skipping_intro,
	}
	packets.send_p2p_packet(0, packet)
	packets.PipeData(packet)

func UpdateMatchInformation(packet_dictionary : Dictionary = {}):
	if packet_dictionary != {}:
		GlobalVariables.debug_round_index_to_end_game_at = packet_dictionary.number_of_rounds - 1
		GlobalVariables.skipping_intro = packet_dictionary.skipping_intro
	ui_number_of_rounds.text = tr("MP_UI NUMBER OF ROUNDS") + " " + str(GlobalVariables.debug_round_index_to_end_game_at + 1)
	ui_check_skip_intro.visible = GlobalVariables.skipping_intro

func CheckStartButton():
	if GlobalSteam.LOBBY_ID != 0 && GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
		ui_button_start_game.visible = true
	else:
		ui_button_start_game.visible = false

func CheckHostLeave():
	if GlobalSteam.LOBBY_ID == 0:
		ui_button_host.visible = true
		ui_button_leave.visible = false
	else:
		ui_button_host.visible = false
		ui_button_leave.visible = true

func CheckHostUI():
	if GlobalSteam.LOBBY_ID == 0:
		ui_skip_intro.visible = false
		ui_skip_intro_checkbox.visible = false
		ui_number_of_rounds.visible = false
		ui_checkbox_number_of_rounds_plus.visible = false
		ui_checkbox_number_of_rounds_minus.visible = false
		#ui_customize_match_settings.visible = false
	else:
		if GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
			ui_skip_intro.visible = true
			ui_skip_intro_checkbox.visible = true
			ui_number_of_rounds.position = pos_number_of_rounds_host
			ui_number_of_rounds.visible = true
			ui_checkbox_button_skip_intro.visible = true
			ui_checkbox_number_of_rounds_plus.visible = true
			ui_checkbox_number_of_rounds_minus.visible = true
			#ui_customize_match_settings.visible = true
		else:
			ui_skip_intro.visible = true
			ui_skip_intro_checkbox.visible = true
			ui_number_of_rounds.position = pos_number_of_rounds_client
			ui_number_of_rounds.visible = true
			ui_checkbox_button_skip_intro.visible = false
			ui_checkbox_number_of_rounds_plus.visible = false
			ui_checkbox_number_of_rounds_minus.visible = false
			#ui_customize_match_settings.visible = false

func SetupMainSceneLoad():
	cursor.SetCursor(false, false)
	speaker_music.stop()
	speaker_enter_main.play()
	animator_intro.play("outro fade in effect")
	animator_game_start.play("show")
	await get_tree().create_timer(3, false).timeout
	speaker_exit.play()
	animator_intro.play("outro cut out")
	await get_tree().create_timer(.60, false).timeout
	viewblocker_main.visible = true

func ExitToMainMenu():
	playing_info_change_sound = false
	lobby.leave_lobby()
	speaker_music.stop()
	cursor.SetCursor(false, false)
	speaker_exit.play()
	animator_intro.play("outro cut out")
	await get_tree().create_timer(.60, false).timeout
	viewblocker_main.visible = true
	await get_tree().create_timer(.2, false).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func CheckLobbyCopyPaste():
	if GlobalSteam.LOBBY_ID == 0:
		ui_copy_id.visible = false
		ui_join_with_id.visible = true
		ui_invite_friends.visible = false
	else:
		ui_copy_id.visible = true
		ui_join_with_id.visible = false
		ui_invite_friends.visible = true
