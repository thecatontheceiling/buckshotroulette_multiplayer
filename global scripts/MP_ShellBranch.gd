class_name MP_ShellBranch extends Node

@export var shell : MeshInstance3D
@export_group("default")
@export var mat_live_default : StandardMaterial3D
@export var mat_blank_default : StandardMaterial3D
@export var mat_unknown_default : StandardMaterial3D
@export_group("colorblind")
@export var mat_live_colorblind : StandardMaterial3D
@export var mat_blank_colorblind : StandardMaterial3D
@export var mat_unknown_colorblind : StandardMaterial3D
@export_group("default_inspecting")
@export var mat_inspecting_live_default : StandardMaterial3D
@export var mat_inspecting_blank_default : StandardMaterial3D
@export var mat_inspecting_unknown_default : StandardMaterial3D
@export_group("colorblind_inspecting")
@export var mat_inspecting_live_colorblind : StandardMaterial3D
@export var mat_inspecting_blank_colorblind : StandardMaterial3D
@export var mat_inspecting_unknown_colorblind : StandardMaterial3D

func SetState(type : String):
	var colorblind = false
	var mat : StandardMaterial3D
	if !colorblind:
		match type:
			"live": mat = mat_live_default
			"blank": mat = mat_blank_default
			"unknown": mat = mat_unknown_default
	else:
		match type:
			"live": mat = mat_live_colorblind
			"blank": mat = mat_blank_colorblind
			"unknown": mat = mat_unknown_colorblind
	shell.set_surface_override_material(1, mat)

func SetState_Inspecting(type : String):
	var colorblind = false
	var mat : StandardMaterial3D
	if !colorblind:
		match type:
			"live": mat = mat_inspecting_live_default
			"blank": mat = mat_inspecting_blank_default
			"unknown": mat = mat_inspecting_unknown_default
	else:
		match type:
			"live": mat = mat_inspecting_live_colorblind
			"blank": mat = mat_inspecting_blank_colorblind
			"unknown": mat = mat_inspecting_unknown_colorblind
	shell.set_surface_override_material(1, mat)
