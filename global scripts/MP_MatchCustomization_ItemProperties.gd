class_name MP_MatchCustomization_ItemProperties extends Node

@export var item_name : String
@export var item_name_loc : String
@export var item_id : int
@export var is_sequence : bool
@export var sequence_index : int
var max_per_player : int
var max_on_table : int
var is_ingame : bool

@export_group("nested")
@export var label_item_name : Label
@export var label_max_per_player : Label
@export var label_max_on_table : Label
@export var checkmark_ingame : TextureRect
@export var label_sequence_number : Label
@export var label_number_of_blanks : Label
@export var label_number_of_lives : Label
@export var label_number_of_items : Label

func _ready():
	if !is_sequence:
		AssignName()
	else:
		AssignSequence()

func AssignName():
	label_item_name.text = item_name_loc

func UpdateItemProperties(max_per_player : int, max_on_table : int, is_ingame : bool):
	label_max_per_player.text = str(max_per_player)
	label_max_on_table.text = str(max_on_table)
	checkmark_ingame.visible = is_ingame

func AssignSequence():
	var verbal_index = sequence_index + 1
	label_sequence_number.text = tr("MP_UI SHELL SEQUENCE") + " " + str(verbal_index) + ":"

func UpdateSequenceProperties(number_of_blanks : int, number_of_lives : int, number_of_items : int):
	if number_of_blanks == -1 or number_of_lives == -1:
		label_number_of_blanks.text = tr("MP_UI NUM OF BLANKS") + " ?"
		label_number_of_lives.text = tr("MP_UI NUM OF LIVES") + " ?"
	else:
		label_number_of_blanks.text = tr("MP_UI NUM OF BLANKS") + " " + str(number_of_blanks)
		label_number_of_lives.text = tr("MP_UI NUM OF LIVES") + " " + str(number_of_lives)
	if number_of_items == -1:
		label_number_of_items.text = tr("MP_UI NUM OF ITEMS") + " ?"
	else:
		label_number_of_items.text = tr("MP_UI NUM OF ITEMS") + " " + str(number_of_items)
