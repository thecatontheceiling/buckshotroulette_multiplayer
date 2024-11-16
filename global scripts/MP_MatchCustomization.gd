class_name MP_MatchCustomization extends Node

@export var packets : PacketManager
@export var lobby_ui : MP_LobbyUI
@export var item_property_branch_array : Array[MP_MatchCustomization_ItemProperties]
@export var sequence_property_branch_array : Array[MP_MatchCustomization_ItemProperties]
@export var charge_array : Array[TextureRect]
@export var label_number_of_rounds : Label
@export var label_editing_current_round : Label
@export var label_starting_health : Label
@export var checkmark_skipping_intro : TextureRect
@export var label_changed_customizations : Label
@export var speaker_press : AudioStreamPlayer2D

var editing_current_round = 0
var right_click_down = false

var default_customization_dictionary : Dictionary = {
	"number_of_rounds": 3,
	"skipping_intro": false,
	"round_property_array": [
		{
			"round_index": 0,
			"starting_health": -1,
			"item_properties": [
				{
					"item_id": 1, #handsaw
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 2, #magnifying glass
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 3, #jammer
					"max_per_player": 1,
					"max_on_table": 1,
					"is_ingame": true}, 
				{
					"item_id": 4, #cigarettes
					"max_per_player": 1,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 5, #beer
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 6, #burner phone
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 8, #adrenaline
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 9, #inverter
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 10, #remote
					"max_per_player": 1,
					"max_on_table": 2,
					"is_ingame": true}],
			"shell_load_properties": [
				{
					"sequence_index": 0,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 1,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 2,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 3,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},]},
		{
			"round_index": 1,
			"starting_health": -1,
			"item_properties": [
				{
					"item_id": 1, #handsaw
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 2, #magnifying glass
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 3, #jammer
					"max_per_player": 1,
					"max_on_table": 1,
					"is_ingame": true}, 
				{
					"item_id": 4, #cigarettes
					"max_per_player": 1,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 5, #beer
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 6, #burner phone
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 8, #adrenaline
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 9, #inverter
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 10, #remote
					"max_per_player": 1,
					"max_on_table": 2,
					"is_ingame": true}],
			"shell_load_properties": [
				{
					"sequence_index": 0,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 1,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 2,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 3,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},]
		},
		{
			"round_index": 2,
			"starting_health": -1,
			"item_properties": [
				{
					"item_id": 1, #handsaw
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 2, #magnifying glass
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 3, #jammer
					"max_per_player": 1,
					"max_on_table": 1,
					"is_ingame": true}, 
				{
					"item_id": 4, #cigarettes
					"max_per_player": 1,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 5, #beer
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 6, #burner phone
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 8, #adrenaline
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 9, #inverter
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 10, #remote
					"max_per_player": 1,
					"max_on_table": 2,
					"is_ingame": true}],
			"shell_load_properties": [
				{
					"sequence_index": 0,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 1,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 2,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 3,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},]
		}
		]
}

var active_customization_dictionary : Dictionary = {}

func _ready():
	if GlobalVariables.active_match_customization_dictionary == {}:
		GlobalVariables.active_match_customization_dictionary = default_customization_dictionary.duplicate(true)

func _input(event):
	if event.is_action_pressed("right_click2"):
		if GlobalVariables.current_button_hovered_over != null:
			right_click_down = true
			GlobalVariables.current_button_hovered_over.get_child(0).OnRightClick()
	if event.is_action_released("right_click2"):
		right_click_down = false
		fs2 = false
	if event.is_action_pressed("scroll_up"):
		if GlobalVariables.current_button_hovered_over != null:
			GlobalVariables.current_button_hovered_over.get_child(0).OnMouseWheelUp()
	if event.is_action_pressed("scroll_down"):
		if GlobalVariables.current_button_hovered_over != null:
			GlobalVariables.current_button_hovered_over.get_child(0).OnMouseWheelDown()

func _process(delta):
	if GlobalVariables.current_button_hovered_over == null:
		right_click_down = false
	checking = right_click_down
	if !right_click_down && !fs2:
		StopHold()
		fs2 = true
	CheckHold()

var t = 0.0
var threshold = 0.3
var checking = false
var fs1 = false
var fs2 = false
func CheckHold():
	if checking:
		t += get_process_delta_time()
	if t > threshold && !fs1:
		if !GlobalVariables.looping_input_main:
			StartHold()
			fs1 = true

func StartHold():
	GlobalVariables.looping_input_secondary = true
	fs2 = false
	looping = true
	LoopInput()

func StopHold():
	GlobalVariables.looping_input_secondary = false
	looping = false
	t = 0
	fs1 = false

var looping = false
var input_loop_delay = .06
func LoopInput():
	while looping:
		if GlobalVariables.current_button_hovered_over != null:
			GlobalVariables.current_button_hovered_over.get_child(0).OnRightClick()
		await get_tree().create_timer(input_loop_delay, false).timeout
	pass

func OnMatchCustomizationEnter():
	editing_current_round = 0
	GetInitialCustomization()
	UpdateDisplay_EditingRound()
	CustomizationDictionary_SetUI(active_customization_dictionary)

func GetInitialCustomization():
	if GlobalVariables.stashed_match_customization_dictionary == {}:
		active_customization_dictionary = default_customization_dictionary.duplicate(true)
	else:
		active_customization_dictionary = GlobalVariables.stashed_match_customization_dictionary.duplicate(true)

func Pipe(alias : String, match_customization_branch : MP_MatchCustomization_Branch):
	match alias:
		"editing round plus":
			if editing_current_round != 2:
				editing_current_round += 1
			UpdateDisplay_EditingRound()
		"editing round minus":
			if editing_current_round != 0:
				editing_current_round -= 1
			UpdateDisplay_EditingRound()
		"number of rounds plus":
			if active_customization_dictionary.number_of_rounds != 3:
				active_customization_dictionary.number_of_rounds += 1
				speaker_press.play()
		"number of rounds minus":
			if active_customization_dictionary.number_of_rounds != 1:
				active_customization_dictionary.number_of_rounds -= 1
				speaker_press.play()
		"starting health plus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					if round.starting_health != 6:
						if round.starting_health == -1: 
							round.starting_health = 0
						round.starting_health += 1
						speaker_press.play()
		"starting health minus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					if round.starting_health != 1 && round.starting_health != 0 && round.starting_health != -1:
						round.starting_health -= 1
						speaker_press.play()
		"starting health random":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					round.starting_health = -1
					speaker_press.play()
		"skip intro":
			active_customization_dictionary.skipping_intro = !active_customization_dictionary.skipping_intro
		"item per player plus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for item_property in round.item_properties:
						if item_property.item_id == match_customization_branch.assigned_item_id:
							if item_property.max_per_player != 8:
								item_property.max_per_player += 1
								speaker_press.play()
		"item per player minus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for item_property in round.item_properties:
						if item_property.item_id == match_customization_branch.assigned_item_id:
							if item_property.max_per_player != 1:
								item_property.max_per_player -= 1
								speaker_press.play()
		"item max on table plus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for item_property in round.item_properties:
						if item_property.item_id == match_customization_branch.assigned_item_id:
							if item_property.max_on_table != 32:
								item_property.max_on_table += 1
								speaker_press.play()
		"item max on table minus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for item_property in round.item_properties:
						if item_property.item_id == match_customization_branch.assigned_item_id:
							if item_property.max_on_table != 1:
								item_property.max_on_table -= 1
								speaker_press.play()
		"is ingame":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for item_property in round.item_properties:
						if item_property.item_id == match_customization_branch.assigned_item_id:
							item_property.is_ingame = !item_property.is_ingame
		"shell sequence random":
			for round in active_customization_dictionary.round_property_array:
				for shell_load in round.shell_load_properties:
					if shell_load.sequence_index == match_customization_branch.assigned_sequence_index:
						shell_load.number_of_blanks = -1
						shell_load.number_of_lives = -1
		"number of blanks plus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for shell_load in round.shell_load_properties:
						if shell_load.sequence_index == match_customization_branch.assigned_sequence_index:
							if shell_load.number_of_blanks == -1:
								shell_load.number_of_blanks = 1
								shell_load.number_of_lives = 0
								speaker_press.play()
							else:
								if (shell_load.number_of_blanks + shell_load.number_of_lives) != 10:
									shell_load.number_of_blanks += 1
									speaker_press.play()
		"number of blanks minus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for shell_load in round.shell_load_properties:
						if shell_load.sequence_index == match_customization_branch.assigned_sequence_index:
							if (shell_load.number_of_lives + shell_load.number_of_blanks) != 1:
								if shell_load.number_of_blanks != -1 && shell_load.number_of_blanks != 0:
									shell_load.number_of_blanks -= 1
									speaker_press.play()
		"number of lives plus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for shell_load in round.shell_load_properties:
						if shell_load.sequence_index == match_customization_branch.assigned_sequence_index:
							if shell_load.number_of_lives == -1:
								shell_load.number_of_lives = 1
								shell_load.number_of_blanks = 0
								speaker_press.play()
							else:
								if (shell_load.number_of_blanks + shell_load.number_of_lives) != 10:
									shell_load.number_of_lives += 1
									speaker_press.play()
		"number of lives minus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for shell_load in round.shell_load_properties:
						if shell_load.sequence_index == match_customization_branch.assigned_sequence_index:
							if (shell_load.number_of_lives + shell_load.number_of_blanks) != 1:
								if shell_load.number_of_lives != -1 && shell_load.number_of_lives != 0:
									shell_load.number_of_lives -= 1
									speaker_press.play()
		"number of items plus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for shell_load in round.shell_load_properties:
						if shell_load.sequence_index == match_customization_branch.assigned_sequence_index:
								if shell_load.number_of_items != 8:
									shell_load.number_of_items += 1
									speaker_press.play()
		"number of items minus":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for shell_load in round.shell_load_properties:
						if shell_load.sequence_index == match_customization_branch.assigned_sequence_index:
							if shell_load.number_of_items != 0 && shell_load.number_of_items != -1:
								shell_load.number_of_items -= 1
								speaker_press.play()
		"number of items random":
			for round in active_customization_dictionary.round_property_array:
				if round.round_index == editing_current_round:
					for shell_load in round.shell_load_properties:
						if shell_load.sequence_index == match_customization_branch.assigned_sequence_index:
							shell_load.number_of_items = -1
		"revert to default":
			active_customization_dictionary = default_customization_dictionary.duplicate(true)
		"cancel changes":
			lobby_ui.ExitMatchCustomization()
		"save changes and return":
			GlobalVariables.stashed_match_customization_dictionary = active_customization_dictionary.duplicate(true)
			CheckMatchCustomizationDifferences()
			lobby_ui.ExitMatchCustomization()
	CustomizationDictionary_SetUI(active_customization_dictionary)

func CheckMatchCustomizationDifferences():
	print("checking diffs")
	if GlobalVariables.stashed_match_customization_dictionary == {}: GlobalVariables.stashed_match_customization_dictionary = default_customization_dictionary.duplicate(true)
	if (GlobalSteam.HOST_ID != GlobalSteam.STEAM_ID) && !GlobalVariables.mp_debugging: return
	GlobalVariables.active_match_customization_dictionary = GlobalVariables.stashed_match_customization_dictionary.duplicate(true)
	var skipping_intro : bool = GlobalVariables.active_match_customization_dictionary.skipping_intro
	var number_of_rounds : int = GlobalVariables.active_match_customization_dictionary.number_of_rounds
	var item_distribution_changed : bool = ItemDistributionChanged(default_customization_dictionary, GlobalVariables.active_match_customization_dictionary)
	var starting_health_changed : bool = StartingHealthChanged(default_customization_dictionary, GlobalVariables.active_match_customization_dictionary)
	var shell_sequence_changed : bool = ShellSequenceChanged(default_customization_dictionary, GlobalVariables.active_match_customization_dictionary)
	var packet = {
		"packet category": "MP_LobbyManager",
		"packet alias": "update match customization",
		"packet_id": 34,
		"sent_from": "host",
		"skipping_intro": skipping_intro,
		"number_of_rounds": number_of_rounds,
		"item_distribution_changed": item_distribution_changed,
		"starting_health_changed": starting_health_changed,
		"shell_sequence_changed": shell_sequence_changed,
	}
	packets.send_p2p_packet(0, packet)
	packets.PipeData(packet)

func ReceivePacket_MatchCustomization(packet : Dictionary):
	UpdateMatchCustomizationUI(packet)

func UpdateMatchCustomizationUI(dict : Dictionary):
	if dict == {}: 
		GlobalVariables.skipping_intro = false
		GlobalVariables.debug_round_index_to_end_game_at = 2
		return
	GlobalVariables.skipping_intro = dict.skipping_intro
	GlobalVariables.debug_round_index_to_end_game_at = dict.number_of_rounds - 1
	GlobalVariables.previous_match_customization_differences = dict.duplicate()
	if dict.skipping_intro == false && dict.number_of_rounds == 3 && !dict.item_distribution_changed&& !dict.starting_health_changed&& !dict.shell_sequence_changed:
		label_changed_customizations.text = ""
		return
	var fullstring = tr("MP_CUSTOMIZED") + "\n"
	if dict.skipping_intro: fullstring = fullstring + "\n" + tr("MP_UI SKIP INTRO")
	fullstring = fullstring + "\n" + tr("MP_UI NUMBER OF ROUNDS") + " " + str(dict.number_of_rounds)
	if dict.item_distribution_changed: fullstring = fullstring + "\n" + tr("MP_UI ITEM DISTRIBUTION").replace(":", "")
	if dict.starting_health_changed: fullstring = fullstring + "\n" + tr("MP_UI STARTING HEALTH").replace(":", "")
	if dict.shell_sequence_changed: fullstring = fullstring + "\n" + tr("MP_UI SHELL SEQUENCE").replace(":", "")
	label_changed_customizations.text = fullstring

func ClearMatchCustomizationUI():
	GlobalVariables.previous_match_customization_differences = {}
	label_changed_customizations.text = ""

func ItemDistributionChanged(default, active):
	var changed = false
	for round_active in active.round_property_array:
		for item_property_active in round_active.item_properties:
			for round_default in default.round_property_array:
				for item_property_default in round_default.item_properties:
					if item_property_active.item_id == item_property_default.item_id:
						if item_property_active != item_property_default:
							changed = true
	return changed

func StartingHealthChanged(default, active):
	var changed = false
	for round_active in active.round_property_array:
		for round_default in default.round_property_array:
			if round_default.round_index == round_active.round_index:
				if round_default.starting_health != round_active.starting_health:
					changed = true
	return changed

func ShellSequenceChanged(default, active):
	var changed = false
	for round_active in active.round_property_array:
		for seq_active in round_active.shell_load_properties:
			for round_default in default.round_property_array:
				for seq_default in round_default.shell_load_properties:
					if seq_active.sequence_index == seq_default.sequence_index:
						if seq_active != seq_default:
							changed = true
	return changed

func UpdateDisplay_EditingRound():
	var verbal_round_number = editing_current_round + 1
	label_editing_current_round.text = tr("MP_UI EDITING ROUND") + " " + str(verbal_round_number)

func CustomizationDictionary_SetUI(dict : Dictionary):
	#set number of rounds
	label_number_of_rounds.text = tr("MP_UI NUMBER OF ROUNDS") + " " + str(dict.number_of_rounds)
	#set skipping intro
	checkmark_skipping_intro.visible = dict.skipping_intro
	#set health
	for charge in charge_array:
		charge.visible = false
	for round in dict.round_property_array:
		if round.round_index == editing_current_round:
			if round.starting_health != -1:
				label_starting_health.text = tr("MP_UI STARTING HEALTH")
				for i in range(round.starting_health):
					charge_array[i].visible = true
			else:
				label_starting_health.text = tr("MP_UI STARTING HEALTH") + " ?"
	#set item properties
	for round in dict.round_property_array:
		if round.round_index == editing_current_round:
			for item_property in round.item_properties:
				for branch in item_property_branch_array:
					if branch.item_id == item_property.item_id:
						branch.UpdateItemProperties(item_property.max_per_player, item_property.max_on_table, item_property.is_ingame)
	#set shell sequence properties:
	for round in dict.round_property_array:
		if round.round_index == editing_current_round:
			for shell_load in round.shell_load_properties:
				for branch in sequence_property_branch_array:
					if branch.sequence_index == shell_load.sequence_index:
						branch.UpdateSequenceProperties(shell_load.number_of_blanks, shell_load.number_of_lives, shell_load.number_of_items)


























