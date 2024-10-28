class_name MP_Intro extends Node

@export var instance_handler : MP_UserInstanceHandler
@export var intermed : MP_InteractionIntermed
@export var animator_intro : AnimationPlayer
@export var animator_hustler : AnimationPlayer
@export var camera_intro : Camera3D
@export var music : MP_MusicManager
@export var filter : MP_FilterController
@export var debug : MP_EditorDebug
@export var cam_shaker : MP_CameraShaker
@export var animator_window_emission : AnimationPlayer
@export var animator_window_emission_new : AnimationPlayer
@export var ctrl_exterior_wind : MP_SpeakerController
@export var ctrl_van : SpeakerController3D
@export var dancer_array : Array[Node3D]

@export var speaker_van : AudioStreamPlayer3D
@export var speaker_wind : AudioStreamPlayer2D
@export var speaker_interior_vent : AudioStreamPlayer3D
@export var speaker_fan : AudioStreamPlayer3D
@export var speaker_fan_high : AudioStreamPlayer3D

func _ready():
	SetupDancers()

func SetupDancers():
	var anim_array = ["dance2", "dance1"]
	var anim_index = -1
	for i in range(dancer_array.size()):
		await get_tree().create_timer(.1, false).timeout
		anim_index += 1
		if anim_index == 2: anim_index = 0
		var animator : AnimationPlayer = dancer_array[i].get_child(1)
		animator.play(anim_array[anim_index])

func MainIntro_Skip():
	await get_tree().create_timer(1, false).timeout
	music.LoadTrack(0, true, false)
	SwapCamera()
	filter.PanLowPass_In()
	debug.SetViewblockerVis(false)
	await get_tree().create_timer(1, false).timeout

func MainIntroSetup():
	await get_tree().create_timer(1, false).timeout
	StartIntroSequence()
	await get_tree().create_timer(16.73, false).timeout
	SwapCamera()
	await get_tree().create_timer(.2, false).timeout

func SwapCamera():
	camera_intro.current = false
	intermed.intermed_properties.cam.cam.current = true

func StartIntroSequence():
	camera_intro.current = true
	intermed.intermed_properties.cam.cam.current = false
	animator_intro.play("RESET")
	speaker_wind.play()
	await get_tree().create_timer(1.23, false).timeout
	hitting = true
	BpmHit()
	cam_shaker.Shake()
	music.LoadTrack(0, true, false)
	speaker_interior_vent.play()
	speaker_fan_high.play()
	speaker_fan.play()
	speaker_van.play()
	animator_intro.play("global intro socket " + str(intermed.intermed_properties.socket_number))
	debug.SetViewblockerVis(false)
	StartLowPass()
	StartHustlerAnimation()

var hitting = false
var am = 0
func BpmHit():
	while hitting:
		animator_window_emission_new.play("hit both")
		am += 1
		if am < 7:
			cam_shaker.Shake()
		await get_tree().create_timer(.39, false).timeout
		pass
	pass

func StartLowPass():
	await get_tree().create_timer(9.42, false).timeout
	ctrl_exterior_wind.FadeOut()
	ctrl_van.FadeOut()
	filter.PanLowPass_In()

func StartHustlerAnimation():
	await get_tree().create_timer(2.5, false).timeout
	animator_hustler.play("hustler inspect vehicle loop")
