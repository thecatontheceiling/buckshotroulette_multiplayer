class_name MP_UserCustomization extends Node

@export var properties : MP_UserInstanceProperties
@export var customization_mesh_by_id_head : Array[Node3D]
@export var main_hand_instance_array : Array[MP_MainHandInstance]

func _ready():
	await get_tree().create_timer(1, false).timeout
	var temp_id_head = 0
	var temp_id_hand_R = 0
	var temp_id_hand_L = 0
	if properties.socket_number == 0: temp_id_head = 4; temp_id_hand_R = 1; temp_id_hand_L = 1
	if properties.socket_number == 1: temp_id_head = 2; temp_id_hand_R = 1; temp_id_hand_L = 1
	if properties.socket_number == 2: temp_id_head = 4; temp_id_hand_R = 1; temp_id_hand_L = 2
	if properties.socket_number == 3: temp_id_head = 3; temp_id_hand_R = 2; temp_id_hand_L = 2
	var dict = {
		"user_customization_id_head": temp_id_head,
		"user_customization_id_hand_R": temp_id_hand_R,
		"user_customization_id_hand_L": temp_id_hand_L,
	}
	ApplyMainCustomization(dict)

func ApplyMainCustomization(with_dictionary : Dictionary):
	var user_customization_id_head = with_dictionary.values()[0]
	var user_customization_id_hand_R = with_dictionary.values()[1]
	var user_customization_id_hand_L = with_dictionary.values()[2]
	ApplyHeadCustomization(user_customization_id_head)
	for hand_instance in main_hand_instance_array:
		hand_instance.ApplyHandCustomization("R", user_customization_id_hand_R)
	for hand_instance in main_hand_instance_array:
		hand_instance.ApplyHandCustomization("L", user_customization_id_hand_L)

func ApplyHeadCustomization(with_id : int):
	for head_mesh in customization_mesh_by_id_head:
		head_mesh.visible = false
	customization_mesh_by_id_head[with_id].visible = true
