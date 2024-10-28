class_name MP_BriefcaseMachine extends Node

@export var properties : MP_UserInstanceProperties
@export var parent : Node3D
@export var animator_firstperson : AnimationPlayer
@export var animator_thirdperson : AnimationPlayer
@export var speaker_fp_briefcase_machine : AudioStreamPlayer2D
@export var speaker_tp_briefcase_machine : AudioStreamPlayer2D
@export var speaker_win : AudioStreamPlayer2D

func GrabBriefcase_FirstPerson():
	properties.cam.moving = false
	var default_energy = properties.intermediary.light_center.light_energy
	properties.intermediary.light_center_controller.LerpEnergy(properties.intermediary.light_center.light_energy, 0, -1.8, .8)
	properties.intermediary.animator_globalcenterlight.play("move away")
	speaker_fp_briefcase_machine.play()
	animator_firstperson.play("receive briefcase first person")
	await get_tree().create_timer(6.26, false).timeout
	properties.intermediary.animator_globalcenterlight.play("move back")
	properties.intermediary.light_center_controller.LerpEnergy(properties.intermediary.light_center.light_energy, default_energy, -1.8, .8)

func GrabBriefcase_ThirdPerson():
	Oscillators()
	var default_energy = properties.intermediary.light_center.light_energy
	properties.intermediary.light_center_controller.LerpEnergy(properties.intermediary.light_center.light_energy, 0, -1.8, .8)
	properties.intermediary.animator_globalcenterlight.play("move away")
	animator_thirdperson.play("receive briefcase third person")
	speaker_tp_briefcase_machine.play()
	await get_tree().create_timer(6.26, false).timeout
	properties.intermediary.animator_globalcenterlight.play("move back")
	properties.intermediary.light_center_controller.LerpEnergy(properties.intermediary.light_center.light_energy, default_energy, -1.8, .8)

func Oscillators():
	await get_tree().create_timer(2.5, false).timeout
	properties.PauseOscillation()
	await get_tree().create_timer(2.82, false).timeout
	properties.ResumeOscillation()
