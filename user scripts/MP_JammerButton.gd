class_name MP_JammerButton extends Node

@export var jammer : MP_Jammer
@export var interaction_branch : MP_InteractionBranch
@export var separate_lerp : MP_SeparateLerp

var lerp_dur = .05
var curve_value = 1
var pos_y_up = 0.096
var pos_y_down = 0.01

func Press():
	jammer.GetInput(interaction_branch.interactionAlias_sub)
	interaction_branch.interactionAllowed = false
	var pos_start = Vector3(separate_lerp.obj.transform.origin.x, pos_y_up, separate_lerp.obj.transform.origin.z)
	var pos_end = Vector3(separate_lerp.obj.transform.origin.x, pos_y_down, separate_lerp.obj.transform.origin.z) 
	var rot_start = separate_lerp.obj.rotation_degrees
	separate_lerp.StartLerp(pos_start, pos_end, rot_start, rot_start, curve_value, lerp_dur)
	await get_tree().create_timer(lerp_dur, false).timeout
	separate_lerp.StartLerp(pos_end, pos_start, rot_start, rot_start, curve_value, lerp_dur)
	interaction_branch.interactionAllowed = true
