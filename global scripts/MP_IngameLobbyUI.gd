class_name MP_IngameLobbyUI extends Node

@export var intermediary : MP_InteractionIntermed
@export var ui_parent : Control
@export var lobby : LobbyManager
@export var instance_array : Array[Control]
@export var button_continue : Control
@export var button_disconnect : Control
@export var button_confirm_yes : Control
@export var button_confirm_no : Control
@export var confirmation_text : Label

@export var btn_continue : Button
@export var btn_no : Button
var previous_focus_before_entering_ui : Control

var segment_array = []

func _ready():
	Steam.avatar_loaded.connect(_on_loaded_avatar)
	HideConfirmation()
	ui_parent.visible = false
	for instance in instance_array:
		segment_array.append(instance.get_child(0))
	for segment in segment_array:
		segment.get_parent().visible = false
	await get_tree().create_timer(1, false).timeout
	UpdateUserList()

var viewing_ui = false
var toggle_allowed = true
var ignoring_viewing = false
func ToggleUI():
	if !toggle_allowed: return
	viewing_ui = !viewing_ui
	if viewing_ui:
		ignoring_viewing = true
		if !intermediary.intermed_properties.cursor.cursor_visible:
			intermediary.intermed_properties.cursor.checking_options = true
			intermediary.intermed_properties.cursor.SetCursor(true, false)
		ui_parent.visible = true
		SetInitialFocus()
	else:
		HideConfirmation()
		ui_parent.visible = false
		intermediary.intermed_properties.cursor.SetCursor(intermediary.intermed_properties.cursor.cursor_visible_after_toggle, false)
		RevertInitialFocus()
	ignoring_viewing = false

func SetInitialFocus():
	if intermediary.intermed_properties.controller.previousFocus != null:
		previous_focus_before_entering_ui = intermediary.intermed_properties.controller.previousFocus
	if intermediary.intermed_properties.cursor.controller_active: btn_continue.grab_focus()
	intermediary.intermed_properties.controller.previousFocus = btn_continue

func RevertInitialFocus():
	if previous_focus_before_entering_ui != null:
		if intermediary.intermed_properties.cursor.controller_active: previous_focus_before_entering_ui.grab_focus()
		intermediary.intermed_properties.controller.previousFocus = previous_focus_before_entering_ui

func ShowConfirmation():
	button_continue.visible = false
	button_disconnect.visible = false
	button_confirm_yes.visible = true
	button_confirm_no.visible = true
	confirmation_text.visible = true
	for segment in segment_array:
		segment.ui_kick.get_child(0).focus_mode = Control.FOCUS_NONE
	if intermediary.intermed_properties.cursor.controller_active: btn_no.grab_focus()
	intermediary.intermed_properties.controller.previousFocus = btn_no

func HideConfirmation():
	return
	button_continue.visible = true
	button_disconnect.visible = true
	button_confirm_yes.visible = false
	button_confirm_no.visible = false
	confirmation_text.visible = false
	for segment in segment_array:
		segment.ui_kick.get_child(0).focus_mode = Control.FOCUS_ALL
	if intermediary.intermed_properties.cursor.controller_active: btn_continue.grab_focus()
	intermediary.intermed_properties.controller.previousFocus = btn_continue

func UpdateUserList():
	var b : Button
	for segment in segment_array:
		segment.get_parent().visible = false
	var active_index = 0
	for segment in segment_array:
		segment.get_parent().visible = false
		segment.ui_kick.visible = false
	for member in GlobalSteam.LOBBY_MEMBERS:
		if member.steam_id == GlobalSteam.HOST_ID:
			segment_array[0].AssignMember(member.steam_id, member.steam_name)
		else:
			active_index += 1
			segment_array[active_index].AssignMember(member.steam_id, member.steam_name)
		if !GlobalVariables.mp_debugging: 
			print("attempting to get avatar for member: ", member)
			Steam.getPlayerAvatar(3, member.steam_id)
	for i in range(GlobalSteam.LOBBY_MEMBERS.size()):
		segment_array[i].get_parent().visible = true
	if GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID:
		for segment in segment_array:
			segment.ui_kick.visible = false
			if segment.user_id != GlobalSteam.STEAM_ID:
				print("set kick ui visible. segment user id: ", segment.user_id, " globalsteam id: ", GlobalSteam.STEAM_ID)
				segment.ui_kick.visible = true

func ApplyProfilePicture(for_user_id : int, texture : ImageTexture):
	print("applying profile picture for id: ", for_user_id)
	for segment in segment_array:
		if segment.user_id == for_user_id:
			segment.ui_profile_picture.texture = texture
			break

func _on_loaded_avatar(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
	var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
	if avatar_size > 128:
		avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	
	# Apply the image to a texture
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
	print("got avatar for: ", user_id, " texture: ", avatar_texture)
	ApplyProfilePicture(user_id, avatar_texture)
