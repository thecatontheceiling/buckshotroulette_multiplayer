class_name MP_LobbyUI extends Node

@export var packets : PacketManager
@export var cursor : MP_CursorManager
@export var lobby : LobbyManager
@export var match_customization : MP_MatchCustomization
@export var ui_host : Array[Control]
@export var ui_member : Array[Control]

@export_group("lobby scene intermediary")
@export var speaker_button_press : AudioStreamPlayer2D
@export var speaker_button_hover : AudioStreamPlayer2D
@export var lobby_manager : LobbyManager
@export_group("")

@export var ui_parent_lobby_home : Control
@export var ui_parent_match_customization : Control

@export var ui_button_host : Control
@export var ui_button_leave : Control
@export var ui_button_start_game : Control
@export var ui_copy_id : Control
@export var ui_join_with_id : Control
@export var ui_invite_friends : Control
@export var ui_skip_intro : Control
@export var ui_skip_intro_checkbox : Control
@export var ui_number_of_rounds : Label
@export var ui_checkbox_number_of_rounds_plus : Control
@export var ui_checkbox_number_of_rounds_minus : Control
@export var ui_checkbox_button_skip_intro : Button
@export var ui_check_skip_intro : Control
@export var ui_checking_animation : Control
@export var ui_parent_popup_window : Control
@export var ui_label_popup : Label
@export var ui_match_customization : Label
@export var ui_match_customization_first_focus : Control

@export var button_class_popup_close : Control
@export var button_class_host : Control
@export var button_class_leave : Control
@export var button_class_start : Control

@export var pos_number_of_rounds_client : Vector2
@export var pos_number_of_rounds_host : Vector2
@export var pos_lobby_id_console_client : Vector2
@export var pos_lobby_id_console_host : Vector2
@export var ui_label_lobby_id_console : Control

@export var array_members : Array[Label]
@export var array_kick : Array[Control]
@export var array_circles : Array[Control]

@export var animator_popup : AnimationPlayer
@export var animator_intro : AnimationPlayer
@export var speaker_music : AudioStreamPlayer2D
@export var speaker_intro : AudioStreamPlayer2D
@export var speaker_info_change : AudioStreamPlayer2D
@export var speaker_enter_main : AudioStreamPlayer2D
@export var speaker_exit : AudioStreamPlayer2D
@export var viewblocker_main : Control
@export var animator_game_start : AnimationPlayer
@export var debug_timeouts_enabled : Control

func _ready():
	GlobalVariables.cursor_state_after_toggle = false
	cursor.SetCursor(false, false)
	UpdatePlayerList()
	
	if GlobalVariables.running_short_intro_in_lobby_scene:
		ShortIntro()
		if GlobalSteam.LOBBY_ID != 0:
			if GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
				Steam.setLobbyJoinable(GlobalSteam.LOBBY_ID, true)
	else:
		LongIntro()
	GlobalVariables.running_short_intro_in_lobby_scene = false
	SetWidth()
	
	if GlobalSteam.LOBBY_ID == 0:
		match_customization.ClearMatchCustomizationUI()
	else:
		match_customization.UpdateMatchCustomizationUI(GlobalVariables.previous_match_customization_differences)

func _process(delta):
	CheckHostLeave()
	CheckLobbyCopyPaste()
	CheckHostUI()
	CheckStartButton()
	FailsafeFocusUI()
	DebugLabel()
	CheckLowerConsolePosition()

func DebugLabel():
	debug_timeouts_enabled.visible = GlobalVariables.timeouts_enabled

func CheckLowerConsolePosition():
	if GlobalSteam.LOBBY_ID != 0:
		if GlobalSteam.HOST_ID == GlobalSteam.STEAM_ID:
			ui_label_lobby_id_console.position = pos_lobby_id_console_host
		else:
			ui_label_lobby_id_console.position = pos_lobby_id_console_client
	else:
		ui_label_lobby_id_console.position = pos_lobby_id_console_client

func GetFirstUIFocus():
	var first_focus : Control
	if GlobalSteam.LOBBY_ID == 0:
		first_focus = button_class_host
	else:
		first_focus = button_class_leave
	return first_focus

var fs_focus_ui = false
func FailsafeFocusUI():
	if !fs_focus_ui:
		if cursor.controller.previousFocus == button_class_start && button_class_start.get_parent().visible == false:
			if GlobalVariables.controllerEnabled or cursor.controller_active:
				GetFirstUIFocus().grab_focus()
			cursor.controller.previousFocus = GetFirstUIFocus()
			fs_focus_ui = true

func EnterMatchCustomization():
	ui_parent_lobby_home.visible = false
	ui_parent_match_customization.visible = true
	match_customization.OnMatchCustomizationEnter()
	if GlobalVariables.controllerEnabled or cursor.controller_active:
		ui_match_customization_first_focus.grab_focus()
	cursor.controller.previousFocus = ui_match_customization_first_focus

func ExitMatchCustomization():
	ui_parent_match_customization.visible = false
	ui_parent_lobby_home.visible = true
	if GlobalVariables.controllerEnabled or cursor.controller_active:
		GetFirstUIFocus().grab_focus()
	cursor.controller.previousFocus = GetFirstUIFocus()

func ShortIntro():
	await get_tree().create_timer(.1, false).timeout
	animator_intro.play("short intro")
	speaker_music.play()
	await get_tree().create_timer(2.5, false).timeout
	GlobalVariables.cursor_state_after_toggle = true
	cursor.SetCursor(true, true)
	if !lobby.viewing_popup:
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
	GlobalVariables.cursor_state_after_toggle = true
	cursor.SetCursor(true, true)
	if GlobalVariables.controllerEnabled:
		GetFirstUIFocus().grab_focus()
	cursor.controller.previousFocus = GetFirstUIFocus()

var prev_members = []
var fs = false
var playing_info_change_sound = true
func UpdatePlayerList():
	CheckAllVersions()
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

func ShowPopupWindow(with_message : String):
	lobby.viewing_popup = true
	animator_popup.play("show")
	ui_label_popup.text = with_message
	ui_parent_popup_window.visible = true
	if GlobalVariables.controllerEnabled or cursor.controller_active:
		button_class_popup_close.grab_focus()
	cursor.controller.previousFocus = button_class_popup_close

func ClosePopupWindow():
	if GlobalVariables.returning_to_main_menu_on_popup_close:
		ExitAfterClosingPopupWindow()
		GlobalVariables.returning_to_main_menu_on_popup_close = false
	lobby.viewing_popup = false
	animator_popup.play("hide")
	await get_tree().create_timer(.26, false).timeout
	ui_parent_popup_window.visible = false
	if GlobalVariables.controllerEnabled or cursor.controller_active:
		GetFirstUIFocus().grab_focus()
	cursor.controller.previousFocus = GetFirstUIFocus()

func ExitAfterClosingPopupWindow():
	await get_tree().create_timer(.2, false).timeout
	ExitToMainMenu()

func OpenDiscordLink():
	OS.shell_open(GlobalVariables.discord_link)

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

var all_versions_matching = false
func CheckAllVersions():
	var steam_ids_currently_connected = []
	for member in GlobalSteam.LOBBY_MEMBERS:
		steam_ids_currently_connected.append(member.steam_id)
	var c = 0
	for steam_id in steam_ids_currently_connected:
		if steam_id in GlobalVariables.steam_id_version_checked_array:
			c += 1
	if c == steam_ids_currently_connected.size():
		all_versions_matching = true
	else:
		all_versions_matching = false

func CheckStartButton():
	if GlobalSteam.LOBBY_ID != 0 && GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
		if all_versions_matching && GlobalSteam.LOBBY_MEMBERS.size() != 1:
			ui_button_start_game.visible = true
			ui_checking_animation.visible = false
		if all_versions_matching && GlobalSteam.LOBBY_MEMBERS.size() == 1:
			ui_button_start_game.visible = false
			ui_checking_animation.visible = false
			fs_focus_ui = false
		if !all_versions_matching && GlobalSteam.LOBBY_MEMBERS.size() > 1:
			ui_button_start_game.visible = false
			ui_checking_animation.visible = true
			fs_focus_ui = false
	else:
		ui_button_start_game.visible = false
		ui_checking_animation.visible = false
		fs_focus_ui = false

func CheckHostLeave():
	if GlobalSteam.LOBBY_ID == 0:
		ui_button_host.visible = true
		ui_button_leave.visible = false
	else:
		ui_button_host.visible = false
		ui_button_leave.visible = true

func CheckHostUI():
	if GlobalVariables.mp_debugging:
		ui_match_customization.visible = true
		return
	if GlobalSteam.LOBBY_ID == 0:
		ui_match_customization.visible = false
	else:
		if GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
			ui_match_customization.visible = true
		else:
			ui_match_customization.visible = false

func SetupMainSceneLoad():
	GlobalVariables.cursor_state_after_toggle = false
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
	GlobalVariables.cursor_state_after_toggle = false
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
