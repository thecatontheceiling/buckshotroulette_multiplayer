class_name MP_WinManager extends Node

@export var roundManager : MP_RoundManager
@export var instance_handler : MP_UserInstanceHandler
@export var parent_lightshow : Node3D
@export var parent_lightshow_sub1 : Node3D
@export var parent_lightshow_sub2 : Node3D
@export var lightshow_flicker_delay : float

func _ready():
	parent_lightshow.visible = false

func WinRoutine(winning_socket_number : int = -1):
	roundManager.game_state.MAIN_running_win_routine = true
	var looping_back = true
	print("running win routine with winning socket: ", winning_socket_number)
	for i in instance_handler.instance_property_array:
		if i.socket_number == winning_socket_number:
			var cash = 0
			match roundManager.game_state.MAIN_active_round_index:
				0:
					cash = 70000
				1:
					cash = 75000
				2:
					cash = 80000
			i.stat_amount_of_cash_earned += cash
			if i.is_active:
				i.cam.BeginLerp("home", true)
			i.briefcase_manager.speaker_win.play()
	await get_tree().create_timer(.5, false).timeout
	for i in instance_handler.instance_property_array:
			i.health_counter.CancelBlink()
			i.health_counter.ClearDisplay()
	SetLightShow(true)
	await get_tree().create_timer(2, false).timeout
	if roundManager.game_state.MAIN_active_round_index == GlobalVariables.debug_round_index_to_end_game_at:
		looping_back = false
		print("win routine: main active round index is last set round index. game has concluded. disabling loopback and running game conclusion instead.")
		if (GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID) or GlobalVariables.mp_debugging:
			print("is host. sending game conclusion packet")
			roundManager.GameConclusion_Packet()
	for i in instance_handler.instance_property_array:
		if i.socket_number == winning_socket_number:
			if i.is_active:
				i.cam.BeginLerp("home", true)
				i.briefcase_manager.GrabBriefcase_FirstPerson()
			else:
				i.briefcase_manager.GrabBriefcase_ThirdPerson()
		if i.socket_number != winning_socket_number:
			var direction_to_look_at = roundManager.GetDirection(i.socket_number, winning_socket_number)
			var str = "opponent " + direction_to_look_at
			LerpCam(i, str, true)
	await get_tree().create_timer(6.4, false).timeout
	SetLightShow(false)
	await get_tree().create_timer(.4, false).timeout
	roundManager.game_state.MAIN_running_win_routine = false
	if looping_back: roundManager.LoopBackAfterWinRoutine()

func SetLightShowStatic(state : bool):
	parent_lightshow_sub1.visible = false
	parent_lightshow_sub2.visible = false
	parent_lightshow.visible = state
	parent_lightshow_sub1.visible = state
	await get_tree().create_timer(.1, false).timeout
	parent_lightshow_sub2.visible = state

func SetLightShow(state : bool):
	parent_lightshow.visible = state
	parent_lightshow_sub1.visible = false; parent_lightshow_sub2.visible = false
	if state:
		looping = true
		Lightshow()
	else:
		looping = false

func LerpCam(property : MP_UserInstanceProperties, string : String, slower : bool):
	#await get_tree().create_timer(1.5, false).timeout
	property.cam.BeginLerp(string, slower)

var looping = false
func Lightshow():
	while(looping):
		parent_lightshow_sub1.visible = false
		parent_lightshow_sub2.visible = true
		await get_tree().create_timer(lightshow_flicker_delay, false).timeout
		parent_lightshow_sub1.visible = true
		parent_lightshow_sub2.visible = false
		await get_tree().create_timer(lightshow_flicker_delay, false).timeout
		pass
	pass
