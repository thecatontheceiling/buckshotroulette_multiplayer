class_name MP_BurnerPhone extends Node

@export var properties : MP_UserInstanceProperties
var game_state : MP_GameStateManager

func _ready():
	game_state = properties.intermediary.game_state

func ShowBurnerPhoneDialogue():
	properties.dialogue.ShowText_Forever(GetBurnerPhoneString(game_state.MAIN_phone_verbal_index, game_state.MAIN_phone_verbal_shell))

func HideBurnerPhoneDialogue():
	properties.dialogue.HideText()

func GetBurnerPhoneString(verbal_index : int, verbal_shell : String):
	var final_string_p1 = "" #ex: THIRD SHELL ...
	var final_string_p2 = "" #ex: ... BLANK.
	var final_string = ""    #ex: FIRST SHELL ... (line break) ... BLANK.
	if verbal_index == -1 or verbal_shell == "":
		final_string = tr("UNFORTUNATE")
	else:
		match verbal_index:
			3: final_string_p1 = tr("SEQUENCE3")
			4: final_string_p1 = tr("SEQUENCE4")
			5: final_string_p1 = tr("SEQUENCE5")
			6: final_string_p1 = tr("SEQUENCE6")
			7: final_string_p1 = tr("SEQUENCE7")
		match verbal_shell:
			"live": final_string_p2	= "... " + tr("LIVEROUND") % ""
			"blank": final_string_p2 = "... " + tr("BLANKROUND") % ""
		final_string = final_string_p1 + "\n" + final_string_p2
	return final_string
