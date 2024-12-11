class_name MP_Matchmaking_Result extends Node

@export var label_number : Label
@export var label_count : Label
@export var button_class : MP_ButtonClassMain

func Set(lobby_number : int, player_count : String, player_limit : String):
	label_number.text = "#_" + str(lobby_number).pad_zeros(3)
	label_count.text = str(player_count) + " / " + player_limit

func AssignLobbyID(id):
	button_class.sub_alias = str(id)
