class_name MP_UserInfoSegment extends Node

@export var ui_profile_picture : TextureRect
@export var ui_user_name : Label
@export var ui_user_type : Label
@export var ui_kick : Control
@export var user_id : float
@export var user_name : String

func AssignMember(steam_id, steam_name):
	ui_user_name.text = steam_name
	if steam_id == GlobalSteam.HOST_ID:
		ui_user_type.text = tr("MP_UI HOST")
	else:
		ui_user_type.text = tr("MP_UI GAMBLER")
	user_id = steam_id
	user_name = steam_name
