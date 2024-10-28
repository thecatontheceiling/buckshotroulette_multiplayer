class_name MP_EnvironmentalEvent extends Node

@export var speaker_ice_machine : AudioStreamPlayer3D
@export var ice_machine : Node3D

func ShowIceMachine():
	ice_machine.visible = true

func StartIceMachine():
	print("starting ice machine in 15 sec")
	await get_tree().create_timer(15, false).timeout
	speaker_ice_machine.play()

func StopIceMachine():
	speaker_ice_machine.stop()
