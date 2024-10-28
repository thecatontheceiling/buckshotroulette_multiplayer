class_name MP_MusicManager extends Node

@export var trackArray : Array[MP_TrackInstance]
@export var speaker_music : AudioStreamPlayer2D
@export var speaker_music_resolve : AudioStreamPlayer2D
@export var speakerController_music : MP_SpeakerController
@export var speakers_to_stop_after_final_death_3d : Array[AudioStreamPlayer3D]
@export var filter : MP_FilterController

var active_track_index = -1

func EndTrack():
	speaker_music.stop()
	active_track_index = -1

func EndTrack_FadeOut():
	speakerController_music.FadeOut()

func FadeInOutroTrack():
	speaker_music_resolve.play()

func StopSpeakersAfterFinalShot():
	for speaker in speakers_to_stop_after_final_death_3d:
		speaker.stop()

func LoadTrack(track_index : int, setting_cutoff_to_max : bool, fading_in : bool):
	active_track_index = track_index
	speakerController_music.SnapVolume(false)
	var currentTrack = null
	if track_index <= 2:
		currentTrack = trackArray[track_index].audiofile
		filter.lowPassDefaultValue = trackArray[track_index].defaultLowPassHz
	filter.effect_lowPass.cutoff_hz = filter.lowPassDefaultValue
	filter.moving = false
	if setting_cutoff_to_max: filter.BeginSnap(20000)
	if currentTrack != null: speaker_music.stream = currentTrack
	speaker_music.play()
	if fading_in:
		speakerController_music.FadeIn()
	else:
		speakerController_music.SnapVolume(true)
