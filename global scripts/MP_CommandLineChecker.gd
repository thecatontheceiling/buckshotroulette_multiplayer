class_name MP_CommandLineChecker extends Node

func _ready():
	check_command_line()

func check_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()
	print("command line args: ", these_arguments)
	if these_arguments.size() > 1 && !GlobalVariables.command_line_checked:
		if these_arguments[1] == "+connect_lobby":
			if int(these_arguments[2]) > 0:
				print("found command line lobby ID: %s" % these_arguments[2])
				JoinGameOutsideLobby(int(these_arguments[2]))
		else:
			print("did not find command line lobby ID. ignoring")
	else:
		print("did not find command line lobby ID. ignoring")

func JoinGameOutsideLobby(lobby_id):
	GlobalVariables.lobby_id_found_in_command_line = lobby_id
	GlobalVariables.running_short_intro_in_lobby_scene = true
	await get_tree().create_timer(.5, false).timeout
	GlobalVariables.command_line_checked = true
	get_tree().change_scene_to_file("res://multiplayer/scenes/mp_lobby.tscn")
