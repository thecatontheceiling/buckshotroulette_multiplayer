class_name MP_BurnerPhone extends Node

@export var properties : MP_UserInstanceProperties
var game_state : MP_GameStateManager

func _ready():
	game_state = properties.intermediary.game_state

func ShowBurnerPhoneDialogue():
	properties.dialogue.ShowText_Forever(GetBurnerPhoneString())

func HideBurnerPhoneDialogue():
	properties.dialogue.HideText()

func GetBurnerPhoneString():
	var current_sequence = game_state.MAIN_active_sequence_dict.sequence_in_shotgun
	var final_string_p1 = "" #ex: THIRD SHELL ...
	var final_string_p2 = "" #ex: ... BLANK.
	var final_string = ""    #ex: FIRST SHELL ... (line break) ... BLANK.
	if current_sequence.size() <= 2: final_string = tr("UNFORTUNATE")
	else:
		var randindex = randi_range(2, current_sequence.size() - 1)
		var verbal_index = randindex; verbal_index += 1
		var verbal_shell = current_sequence[randindex]
		if verbal_index > 7: verbal_index = 7
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
