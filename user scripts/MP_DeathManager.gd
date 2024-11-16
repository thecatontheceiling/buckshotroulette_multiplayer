class_name MP_DeathManager extends Node

@export var properties : MP_UserInstanceProperties
@export var fov_to_set_on_revive : float = 58.5
@export var animator_death_thirdperson : AnimationPlayer
@export var nametag : Node3D
@export var speaker_glimpse : AudioStreamPlayer2D
@export var speaker_defib : AudioStreamPlayer2D
@export var speaker_corpse_fall : AudioStreamPlayer3D
@export var speaker_revive : AudioStreamPlayer3D
@export var defib : Node3D
@export var anim_defib : AnimationPlayer

var user_returned_from_death : bool
var user_reviving : bool
var saturation_original : float

func _ready():
	defib.visible = false
	saturation_original = properties.intermediary.post_processing.environment.adjustment_saturation

func DeathRequest(shot_from_direction : String = ""):
	user_reviving = true
	if properties.health_current == 0:
		if properties.intermediary.game_state.MAIN_active_checking_for_first_death:
			properties.intermediary.game_state.MAIN_active_first_socket_to_die = properties.socket_number
			properties.intermediary.game_state.MAIN_active_checking_for_first_death = false
	properties.stat_number_of_deaths += 1
	if properties.is_active: 
		UserDeath_FirstPerson()
	else:
		UserDeath_ThirdPerson(shot_from_direction)

func UserDeath_FirstPerson():
	user_returned_from_death = false
	await get_tree().create_timer(.1, false).timeout
	properties.FreeLookCameraForUser_Disable()
	properties.is_being_revived = true
	properties.viewblocker.Snap_Opaque()
	properties.MuteAudioOnDeath()
	speaker_glimpse.pitch_scale = randf_range(.8, 1)
	speaker_glimpse.play()
	await get_tree().create_timer(.7, false).timeout
	properties.health_counter.UpdateDisplay()
	if properties.health_current == 0:
		UserDeath_EnterSpectatorMode()
		properties.health_counter.UpdateDisplay()
		properties.is_being_revived = false
	else:
		UserDeath_Revive()

func UserDeath_ThirdPerson(shot_from_direction : String = "ˇ"):
	if shot_from_direction == "self": shot_from_direction = "forward"
	user_returned_from_death = false
	animator_death_thirdperson.play("user death third person shot from " + shot_from_direction)
	PlaySound_CorpseFall()
	nametag.visible = false
	await get_tree().create_timer(.7, false).timeout
	properties.health_counter.UpdateDisplay()
	if properties.health_current == 0:
		UserDeath_EnterSpectatorMode()
		properties.FreeLookCameraForUser_Enable()
		return
	else:
		UserDeath_Revive()

func PlaySound_CorpseFall():
	await get_tree().create_timer(.3, false).timeout
	speaker_corpse_fall.pitch_scale = randf_range(.9, 1)
	speaker_corpse_fall.play()

func UserDeath_Revive(reviving_from_spectator : bool = false):
	if properties.is_active: DefibRevive()
	if !properties.running_fast_revival:
		await get_tree().create_timer(1.3, false).timeout
	StopHandBobbing()
	animator_death_thirdperson.play("user return from death thirdperson")
	if !properties.is_active: speaker_revive.play()
	nametag.visible = true
	await get_tree().create_timer(.7, false).timeout
	await get_tree().create_timer(1.5, false).timeout
	print("user ", properties.user_name, " returned from death!")
	user_returned_from_death = true
	user_reviving = false
	properties.is_spectating = false

func StopHandBobbing():
	if !properties.is_active:
		properties.PauseOscillation()
		await get_tree().create_timer(1.9, false).timeout
		properties.ResumeOscillation()

func DefibRevive():
	if properties.is_spectating:
		properties.viewblocker.FadeIn(.7, -1.8)
	speaker_defib.play()
	await get_tree().create_timer(1.1, false).timeout
	properties.intermediary.post_processing.environment.adjustment_saturation = saturation_original
	properties.cam.cam.fov = fov_to_set_on_revive
	anim_defib.play("RESET")
	defib.visible = true
	properties.intermediary.anim_pp_revive.play("revive brightness")
	properties.cam_shaker.Shake()
	properties.viewblocker.Snap_Transparent()
	properties.intermediary.filter.BeginSnap(20000)
	properties.UnmuteAudioOnRevive()
	properties.intermediary.filter.panDuration = 8
	properties.intermediary.filter.PanLowPass_In()
	await get_tree().create_timer(.8, false).timeout
	anim_defib.play("move away")
	await get_tree().create_timer(1, false).timeout
	properties.FreeLookCameraForUser_Enable()
	properties.is_being_revived = false

func UserDeath_EnterSpectatorMode():
	if properties.is_active:
		properties.is_spectating = true
		if GlobalVariables.greyscale_death:
			properties.intermediary.post_processing.environment.adjustment_saturation = 0.0
		await get_tree().create_timer(.7, false).timeout
		properties.FadeInAudioBus()
		properties.viewblocker.FadeOut(1.5, -1.8)
