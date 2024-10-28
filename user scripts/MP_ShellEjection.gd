class_name MP_ShellEjection extends Node

@export var properties : MP_UserInstanceProperties
@export var animator_eject : AnimationPlayer
@export var animator_fade_out : AnimationPlayer
@export var shell_branch : MP_ShellBranch
@export var speaker_shell_drop : AudioStreamPlayer2D
@export var sounds_shelldrop : Array[AudioStream]

#this shell eject does not change the sequence properties. this is only the visible side of shell ejection. see shotgun interaction RemoveFirstShellFromSequence
func EjectShell():
	var shell_to_eject = properties.intermediary.game_state.MAIN_shell_visible_to_eject
	shell_branch.SetState(shell_to_eject)
	animator_fade_out.play("set visible")
	animator_eject.play("eject shell")
	await get_tree().create_timer(.6, false).timeout
	speaker_shell_drop.pitch_scale = randf_range(.9, 1)
	speaker_shell_drop.stream = sounds_shelldrop[randi_range(0, sounds_shelldrop.size() - 1)]
	speaker_shell_drop.play()

func FadeOutShell():
	animator_fade_out.play("fade out")
