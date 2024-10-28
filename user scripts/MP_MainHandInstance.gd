class_name MP_MainHandInstance extends Node3D

@export var is_R : bool
@export var is_L : bool
@export var default_track : String

@export var customization_mesh_by_id_hand_R : Array[Node3D]
@export var customization_mesh_by_id_hand_L : Array[Node3D]

var animator_R : AnimationPlayer
var animator_L : AnimationPlayer
var parent_R : Node3D
var parent_L : Node3D
var anim_active : AnimationPlayer

var root = self

func _ready():
	animator_R = root.get_child(0).get_child(1)
	animator_L = root.get_child(1).get_child(1)
	parent_R = root.get_child(0)
	parent_L = root.get_child(1)
	if is_R:
		anim_active = animator_R
		if default_track == "track_R_shotgun trigger":
			anim_active.play("track_R_grabbing shotgun")
		else:
			anim_active.play("track_R_reset position")
		anim_active.stop()
		parent_R.visible = true
		parent_L.visible = false
	if is_L:
		anim_active = animator_L
		anim_active.play("track_L_reset position")
		anim_active.stop()
		parent_L.visible = true
		parent_R.visible = false
	anim_active.play(default_track)

func ApplyHandCustomization(for_hand : String, with_id : int):
	if for_hand == "R" && !is_R: return
	if for_hand == "L" && !is_L: return
	for hand in customization_mesh_by_id_hand_R:
		hand.visible = false
	for hand in customization_mesh_by_id_hand_L:
		hand.visible = false
	if for_hand == "R":
		customization_mesh_by_id_hand_R[with_id].visible = true
	if for_hand == "L":
		customization_mesh_by_id_hand_L[with_id].visible = true
