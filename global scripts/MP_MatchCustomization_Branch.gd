class_name MP_MatchCustomization_Branch extends Node

@export var alias : String
@export var alias_right_click : String
@export var alias_scroll_up : String
@export var alias_scroll_down : String
@export var item_properties : MP_MatchCustomization_ItemProperties
@export var is_sequence : bool = false
var assigned_item_id : int
var assigned_sequence_index : int

func _ready():
	AssignID()

func AssignID(): 
	if item_properties != null && !is_sequence:
		assigned_item_id = item_properties.item_id
	if item_properties != null && is_sequence:
		assigned_sequence_index = item_properties.sequence_index
