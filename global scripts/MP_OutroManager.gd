class_name MP_OutroManager extends Node

@export var intermed : MP_InteractionIntermed
@export var club_lights : Array[Node3D]
@export var animator_outro : AnimationPlayer
@export var animator_plane : AnimationPlayer
@export var global_camera : Camera3D
@export var env : WorldEnvironment
@export var env_intro : Environment
@export var env_outro : Environment
@export var light_moon : DirectionalLight3D
@export var light_sky : DirectionalLight3D

@export var ui_parent_match_results : Control
@export var dialogue_results : MP_Dialogue
@export var text_fire_array : Array[MP_TextFire]
@export var animator_exit_in_fader : AnimationPlayer
@export var speaker_shell_load : AudioStreamPlayer2D
@export var exiting_label : Label
@export var speaker_controller_resolve : MP_SpeakerController

@export var label_most_damage : Label
@export var label_most_deaths : Label
@export var label_the_chimney : Label
@export var label_least_careful : Label
@export var label_most_resourceful : Label
@export var label_the_wealthiest : Label

func _ready():
	dialogue_results.get_parent().get_child(0).text = ""

func _process(delta):
	ExitTimer()

func Outro():
	SetupOutroLight()
	animator_plane.play("fly")
	env.environment = env_outro
	global_camera.current = true
	animator_outro.play("show outro")
	intermed.intermed_properties.viewblocker.FadeOut(6, -1.8)
	await get_tree().create_timer(5, false).timeout
	ShowMatchResults()

func ShowMatchResults():
	SetupStatistics()
	dialogue_results.get_parent().visible = true
	dialogue_results.ShowText_Forever(tr("MP_UI MATCH RESULTS"))
	await get_tree().create_timer(1.5, false).timeout
	for s in text_fire_array.size():
		speaker_shell_load.play()
		await get_tree().create_timer(.15, false).timeout
	await get_tree().create_timer(.3, false).timeout
	var increment = 0
	for t in text_fire_array:
		increment += 1
		if increment == text_fire_array.size():
			t.low_pitched = true
			t.max_x += .2
			t.max_y += .2
			t.duration = 3
			t.Reset()
			await get_tree().create_timer(.7, false).timeout
		t.Fire()
		await get_tree().create_timer(.3, false).timeout
	await get_tree().create_timer(2, false).timeout
	animator_exit_in_fader.get_parent().get_parent().visible = true
	exiting_label.text = tr("MP_UI EXITING IN") % str(10)
	animator_exit_in_fader.play("fade in")
	await get_tree().create_timer(1.5, false).timeout
	counting = true

func SetupStatistics():
	var dots = "........................................................"
	
	var name_most_damage = ""
	var name_most_deaths = ""
	var name_the_chimney = ""
	var name_least_careful = ""
	var name_most_resourceful = ""
	var name_the_wealthiest = ""
	
	if !GlobalVariables.mp_debugging:
		if intermed.game_state.MAIN_active_match_result_statistics.id_most_damage != -1: name_most_damage = Steam.getFriendPersonaName(intermed.game_state.MAIN_active_match_result_statistics.id_most_damage)
		else: name_most_damage = "N/A"
		if intermed.game_state.MAIN_active_match_result_statistics.id_most_deaths != -1: name_most_deaths = Steam.getFriendPersonaName(intermed.game_state.MAIN_active_match_result_statistics.id_most_deaths)
		else: name_most_deaths = "N/A"
		if intermed.game_state.MAIN_active_match_result_statistics.id_the_chimney != -1: name_the_chimney = Steam.getFriendPersonaName(intermed.game_state.MAIN_active_match_result_statistics.id_the_chimney)
		else: name_the_chimney = "N/A"
		if intermed.game_state.MAIN_active_match_result_statistics.id_least_careful != 1: name_least_careful = Steam.getFriendPersonaName(intermed.game_state.MAIN_active_match_result_statistics.id_least_careful)
		else: name_least_careful = "N/A"
		if intermed.game_state.MAIN_active_match_result_statistics.id_most_resourceful != -1: name_most_resourceful = Steam.getFriendPersonaName(intermed.game_state.MAIN_active_match_result_statistics.id_most_resourceful)
		else: name_most_resourceful = "N/A"
		if intermed.game_state.MAIN_active_match_result_statistics.id_the_wealthiest != -1: name_the_wealthiest = Steam.getFriendPersonaName(intermed.game_state.MAIN_active_match_result_statistics.id_the_wealthiest)
		else: name_the_wealthiest = "N/A"
	else:
		name_most_damage = str(intermed.game_state.MAIN_active_match_result_statistics.id_most_damage)
		name_most_deaths = str(intermed.game_state.MAIN_active_match_result_statistics.id_most_deaths)
		name_the_chimney = str(intermed.game_state.MAIN_active_match_result_statistics.id_the_chimney)
		name_least_careful = str(intermed.game_state.MAIN_active_match_result_statistics.id_least_careful)
		name_most_resourceful = str(intermed.game_state.MAIN_active_match_result_statistics.id_most_resourceful)
		name_the_wealthiest = str(intermed.game_state.MAIN_active_match_result_statistics.id_the_wealthiest)
	
	label_most_damage.text = tr("MP_UI MOST DAMAGE") + dots; label_most_damage.get_child(2).text = name_most_damage
	label_most_deaths.text = tr("MP_UI MOST DEATHS") + dots; label_most_deaths.get_child(2).text = name_most_deaths
	label_the_chimney.text = tr("MP_UI THE CHIMNEY") + dots; label_the_chimney.get_child(2).text = name_the_chimney
	label_least_careful.text = tr("MP_UI LEAST CAREFUL") + dots; label_least_careful.get_child(2).text = name_least_careful
	label_most_resourceful.text = tr("MP_UI MOST RESOURCEFUL") + dots; label_most_resourceful.get_child(2).text = name_most_resourceful
	label_the_wealthiest.text = tr("MP_UI THE WEALTHIEST") + dots; label_the_wealthiest.get_child(2).text = name_the_wealthiest

var count = 10.9
var counting = false
var finished = false
var fs = false
func ExitTimer():
	if counting:
		if !finished: count -= get_process_delta_time() * .7
		var s = str(int(count))
		if s.length() == 1:
			s = "0" + s
		if count <= 1:
			finished = true
			counting = false
		if !finished: 
			exiting_label.text = tr("MP_UI EXITING IN") % s
		else:
			if !fs:
				MatchResultsFinished()
				fs = true
			exiting_label.text = tr("MP_UI EXITING FINAL")

func MatchResultsFinished():
	speaker_controller_resolve.FadeOut()
	intermed.intermed_properties.viewblocker.FadeIn(3, -1.8)
	await get_tree().create_timer(3.5, false).timeout
	GlobalVariables.disband_lobby_after_exiting_main_scene = false
	intermed.ExitGame()

func SetupOutroLight():
	light_moon.visible = false
	light_sky.visible = true
	for light in club_lights:
		light.visible = false
