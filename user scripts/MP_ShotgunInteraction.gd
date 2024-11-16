class_name MP_ShotgunInteraction extends Node

@export var self_hover_obj : Node3D
@export var cursor : MP_CursorManager
@export var controller : MP_ControllerManager
@export var properties : MP_UserInstanceProperties
@export var animator_shotgun : AnimationPlayer
@export var animator_shotgun_thirdperson : AnimationPlayer
@export var cam : MP_CameraManager
@export var localparent_shotgun : Node3D
@export var localparent_shotgun_cut_segment : Node3D
@export var localanimator_cut_segment : AnimationPlayer
@export var ui_you : Control
@export var look_manager : MP_UserLook
@export var anim_light_muzzle : AnimationPlayer
@export var anim_recoil_thirdperson : AnimationPlayer
@export var anim_recoil_firstperson : AnimationPlayer
@export var anim_muzzle_cone : AnimationPlayer
@export var cam_shaker : MP_CameraShaker
@export var smoke : MP_SmokeParticles
@export var muzzle_flash_plane : Node3D
@export var bp_shotgun_target_selection : Control
@export var btn_shotgun_target_selection_you : Button

@export var speaker_shotgun_foley_firstperson : AudioStreamPlayer2D
@export var speaker_shotgun_foley_thirdperson : AudioStreamPlayer2D
@export var speaker_blank : AudioStreamPlayer2D
@export var speaker_live : AudioStreamPlayer2D
@export var speaker_barrelgrow : AudioStreamPlayer2D
@export var speaker_bodygrow : AudioStreamPlayer2D
@export var sounds_live : Array[AudioStream]
@export var sounds_blank : Array[AudioStream]
@export var sound_fp_pickup_shotgun : AudioStream
@export var sound_fp_shotgun_forward : AudioStream
@export var sound_fp_shotgun_left : AudioStream
@export var sound_fp_shotgun_right : AudioStream
@export var sound_fp_shotgun_self_attempt : AudioStream
@export var sound_fp_shotgun_self_transition : AudioStream
@export var sound_fp_shotgun_drop: AudioStream
@export var sound_tp_pickup_shotgun : AudioStream
@export var sound_tp_shotgun_forward : AudioStream
@export var sound_tp_shotgun_left : AudioStream
@export var sound_tp_shotgun_right : AudioStream
@export var sound_tp_shotgun_self_attempt : AudioStream
@export var sound_tp_shotgun_self_transition : AudioStream
@export var sound_tp_shotgun_drop : AudioStream

var globalparent_shotgun_main : Node3D
var globalparent_shotgun_forestock : Node3D
var globalparent_shotgun_window : Node3D
var globalparent_shotgun_cut_segment_mesh : Node3D

var globalparent_shotgun_main_geometry : GeometryInstance3D

var intermediary : MP_InteractionIntermed
var globalparent_shotgun : Node3D
var globalparent_shotgun_cut_segment : Node3D
var globalanimator_cut_segment : AnimationPlayer
var intbranch_shotgun : MP_InteractionBranch

var active_shooter_socket_target : int
var active_shooter_socket_target_direction : String
var active_shooter_socket_self : int
var active_shooter_shell : String
var active_shooter_sequence_length_after_eject : int
var active_shooter_shotgun_damage : int = 1

func _ready():
	cam.BeginLerp("home")
	intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")
	intbranch_shotgun = intermediary.intbranch_shotgun
	globalparent_shotgun = intermediary.globalparent_shotgun
	globalparent_shotgun_cut_segment = intermediary.globalparent_shotgun_cut_segment
	globalanimator_cut_segment = intermediary.globalanimator_cut_segment
	globalparent_shotgun_main = intermediary.globalparent_shotgun_main
	globalparent_shotgun_forestock = intermediary.globalparent_shotgun_forestock
	globalparent_shotgun_window = intermediary.globalparent_shotgun_window
	globalparent_shotgun_cut_segment_mesh = intermediary.globalparent_shotgun_cut_segment_mesh

func _process(delta):
	Lerp_ShotgunTransparency()

func _unhandled_input(event):
	if GlobalVariables.mp_debug_keys_enabled:
		if (event.is_action_pressed("h") && properties.socket_number == intermediary.game_state.MAIN_active_current_turn_socket && GlobalVariables.mp_debug_keys_enabled):
			var user_properties = properties.intermediary.instance_handler.instance_property_array.duplicate()
			for property in user_properties:
				if property.health_current == 0:
					user_properties.erase(property)
			var socket_to_shoot = user_properties[randi_range(0, user_properties.size() - 1)].socket_number
			var packet = {
			"packet category": "MP_PacketVerification",
			"packet alias": "pickup shotgun request",
			"packet_id": 10,
			"sent_from": "client",
			"sent_from_socket": properties.socket_number,
			}
			intermediary.packets.PipeData(packet)
			await get_tree().create_timer(4, false).timeout
			look_manager.LookAtDirection(GetDirection(properties.socket_number, socket_to_shoot))
			await get_tree().create_timer(.1, false).timeout
			Shoot(null, socket_to_shoot)

func PickupShotgun():
	properties.FreeLookCameraForUser_Disable()
	GlobalVariables.cursor_state_after_toggle = false
	cursor.SetCursor(false, false)
	properties.permissions.SetMainPermission(false)
	properties.permissions.SetItemPermissions(false)
	intbranch_shotgun.interactionAllowed = false
	var packet = {
	"packet category": "MP_PacketVerification",
	"packet alias": "pickup shotgun request",
	"packet_id": 10,
	"sent_from": "client",
	"sent_from_socket": properties.socket_number,
	}
	intermediary.packets.send_p2p_packet_directly_to_host(GlobalSteam.STEAM_ID, packet)
	if GlobalVariables.mp_debugging: intermediary.packets.PipeData(packet)

func DropShotgun():
	if properties.is_active:
		animator_shotgun.play("drop shotgun")
		PlaySound_ShotgunFoley(true, "drop")
		ui_you.get_child(0).play("hide")
		look_manager.checking = false
		for i in range(intermediary.instance_handler.instance_property_array.size()):
			intermediary.instance_handler.instance_property_array[i].hover_pan.Disable()
		await get_tree().create_timer(.39, false).timeout
		SetShotgunVisible_Local(false)
		SetShotgunVisible_Global(true)
	else:
		animator_shotgun_thirdperson.play("drop shotgun thirdperson")
		properties.oscillator_manager.LerpToOriginal("hands")
		PlaySound_ShotgunFoley(false, "drop")
		await get_tree().create_timer(.39, false).timeout
		SetShotgunVisible_Local(false)
		SetShotgunVisible_Global(true)

func ReceivePacket_PickUpShotgun(packet : Dictionary = {}):
	var sent_from = packet.sent_from_socket
	if sent_from == properties.socket_number:
		properties.is_on_secondary_interaction = true
		properties.intermediary.game_state.BeginTimeoutForSocket("shotgun target selection", properties.intermediary.game_state.MAIN_timeout_duration_shotgun_target_selection, properties.socket_number)
		properties.is_holding_shotgun = true
		if properties.is_active:
			PickupShotgun_FirstPerson()
		else:
			PickupShotgun_ThirdPerson(packet)

func PickupShotgun_FirstPerson():
	SetShotgunVisible_Local(true)
	SetShotgunVisible_Global(false)
	PlaySound_ShotgunFoley(true, "pickup")
	animator_shotgun.play("pick up shotgun")
	await get_tree().create_timer(1.15, false).timeout
	cam.BeginLerp("select opponent")
	await get_tree().create_timer(.4, false).timeout
	ui_you.get_child(0).play("show")
	GlobalVariables.cursor_state_after_toggle = true
	cursor.SetCursor(true, true)
	look_manager.checking = true
	#SET HOVER PAN OBJECTS
	for i in range(intermediary.instance_handler.instance_property_array.size()):
		intermediary.instance_handler.instance_property_array[i].hover_pan.SetState()
	SetTargetControllerPrompts(true)

func SetTargetControllerPrompts(state : bool):
	if state:
		bp_shotgun_target_selection.visible = true
		if cursor.controller_active: btn_shotgun_target_selection_you.grab_focus()
		controller.previousFocus = btn_shotgun_target_selection_you
	else:
		bp_shotgun_target_selection.visible = false

func PickupShotgun_ThirdPerson(packet_dictionary : Dictionary = {}):
	SetShotgunVisible_Local(true)
	SetShotgunVisible_Global(false)
	properties.oscillator_manager.LerpToOriginal("hands")
	animator_shotgun_thirdperson.play("pick up shotgun thirdperson")
	PlaySound_ShotgunFoley(false, "pickup")

func Shoot(hoverpan_intbranch : MP_InteractionBranch, overriding_intbranch_with_socket : int = 5):
	properties.intermediary.game_state.StopTimeoutForSocket("turn", properties.socket_number)
	if properties.is_active: ui_you.get_child(0).play("hide")
	var self_socket = properties.socket_number
	var selected_socket
	if overriding_intbranch_with_socket == 5: selected_socket = hoverpan_intbranch.properties.socket_number
	if overriding_intbranch_with_socket != 5: selected_socket = overriding_intbranch_with_socket
	look_manager.checking = false
	
	print("shooting at: ", selected_socket, " from: ", self_socket)
	
	var packet = {
	"packet category": "MP_PacketVerification",
	"packet alias": "shoot user request",
	"packet_id": 12,
	"sent_from": "client",
	"sent_from_socket": self_socket,
	"socket_to_shoot": selected_socket,
	}
	intermediary.packets.send_p2p_packet_directly_to_host(GlobalSteam.STEAM_ID, packet)
	if GlobalVariables.mp_debugging: intermediary.packets.PipeData(packet)
	
	#SET HOVER PAN OBJECTS
	for i in range(intermediary.instance_handler.instance_property_array.size()):
		intermediary.instance_handler.instance_property_array[i].hover_pan.Disable()
	GlobalVariables.cursor_state_after_toggle = false
	cursor.SetCursor(false, false)
	SetTargetControllerPrompts(false)

func ReceivePacket_Shoot(packet_dictionary : Dictionary = {}):
	intermediary.game_state.MAIN_active_sequence_dict.sequence_in_shotgun = packet_dictionary.sequence_in_shotgun
	properties.is_on_secondary_interaction = false
	properties.intermediary.game_state.StopTimeoutForSocket("shotgun target selection", properties.socket_number)
	active_shooter_socket_self = packet_dictionary.shooter_socket_self
	active_shooter_socket_target = packet_dictionary.shooter_socket_target
	active_shooter_shell = packet_dictionary.shooter_shell
	active_shooter_sequence_length_after_eject = packet_dictionary.shooter_sequence_length_after_eject
	active_shooter_socket_target_direction = packet_dictionary.shooter_socket_target_direction
	if packet_dictionary.barrel_sawed_off: 
		active_shooter_shotgun_damage = 2
	else:
		active_shooter_shotgun_damage = 1
	
	var sent_from = packet_dictionary.sent_from_socket
	if sent_from == properties.socket_number:
		if properties.is_active:
			Shoot_FirstPerson(packet_dictionary)
		else:
			Shoot_ThirdPerson(packet_dictionary)

func Shoot_FirstPerson(packet_dictionary : Dictionary = {}):
	animator_shotgun.play("user shoot " + active_shooter_socket_target_direction)
	PlaySound_ShotgunFoley(false, active_shooter_socket_target_direction)
	var time = 3.6
	cam.moving = false
	await get_tree().create_timer(time, false).timeout
	SetShotgunVisible_Global(true)
	SetShotgunVisible_Local(false)
	await get_tree().create_timer(.2, false).timeout
	CheckIfEndingTurn(packet_dictionary)

func Shoot_ThirdPerson(packet_dictionary : Dictionary = {}):
	look_manager.LookAtDirection(active_shooter_socket_target_direction)
	animator_shotgun_thirdperson.play("user shoot " + active_shooter_socket_target_direction + " thirdperson")
	PlaySound_ShotgunFoley(false, active_shooter_socket_target_direction)
	await get_tree().create_timer(.25, false).timeout
	LookAtShooting()
	await get_tree().create_timer(1.9, false).timeout
	ReturnFromLookAtShooting()
	await get_tree().create_timer(1.65, false).timeout
	SetShotgunVisible_Global(true)
	SetShotgunVisible_Local(false)
	CheckIfEndingTurn(packet_dictionary)

func PlaySound_ShotgunFoley(first_person : bool, direction : String):
	var active_stream : AudioStream
	var active_speaker : AudioStreamPlayer2D
	if first_person:
		active_speaker = speaker_shotgun_foley_firstperson
		match direction:
			"pickup":
				active_stream = sound_fp_pickup_shotgun
			"forward":
				active_stream = sound_fp_shotgun_forward
			"left":
				active_stream = sound_fp_shotgun_left
			"right":
				active_stream = sound_fp_shotgun_right
			"self":
				active_stream = sound_fp_shotgun_self_attempt
			"transition":
				active_stream = sound_fp_shotgun_self_transition
			"drop":
				active_stream = sound_fp_shotgun_drop
	else:
		active_speaker = speaker_shotgun_foley_thirdperson
		match direction:
			"pickup":
				active_stream = sound_tp_pickup_shotgun
			"forward":
				active_stream = sound_tp_shotgun_forward
			"left":
				active_stream = sound_tp_shotgun_left
			"right":
				active_stream = sound_tp_shotgun_right
			"self":
				active_stream = sound_tp_shotgun_self_attempt
			"transition":
				active_stream = sound_tp_shotgun_self_transition
			"drop":
				active_stream = sound_tp_shotgun_drop
	active_speaker.stream = active_stream
	active_speaker.play()

func SmokeParticles():
	var smoke_pos : Vector3
	match active_shooter_socket_target_direction:
		"left":
			smoke_pos = Vector3(4.802, 4.605, 8.245)
		"right":
			smoke_pos = Vector3(5.588, 5.625, -10.395)
		"forward":
			smoke_pos = Vector3(1.22, 4.682, -.7)
		"self":
			smoke_pos = Vector3(12.091, 4.061, -.287)
	smoke.SpawnSmoke(smoke_pos)

func BloodParticles():
	var instance_being_shot : MP_UserInstanceProperties
	var splatter_direction : String
	var splatter_rotation : Vector3
	for instance in intermediary.instance_handler.instance_property_array:
		if instance.socket_number == active_shooter_socket_target:
			instance_being_shot = instance
			break
	splatter_direction = GetDirection(active_shooter_socket_target, active_shooter_socket_self)
	match splatter_direction:
		"left":
			splatter_rotation = Vector3(0, 47, 0)
		"forward":
			splatter_rotation = Vector3(0, 0, 0)
		"self":
			splatter_rotation = Vector3(0, 0, 0)
		"right":
			splatter_rotation = Vector3(0, -55, 0)
	if instance_being_shot != null:
		instance_being_shot.particles_shooting.SpawnBlood(splatter_rotation)

var previous_socket : String
func LookAtShooting():
	for instance in intermediary.instance_handler.instance_property_array:
		if instance.is_active:
			previous_socket = instance.cam.activeSocket
			var dir_1 = GetDirection(instance.socket_number, properties.socket_number)
			var dir_2 = GetDirection(instance.socket_number, active_shooter_socket_target)
			instance.cam.BeginLerp("user shoot " + dir_1 + " " + dir_2)

func ReturnFromLookAtShooting():
	for instance in intermediary.instance_handler.instance_property_array:
		if instance.is_active:
			instance.cam.BeginLerp(previous_socket)

func EndTurnRequest():
	pass

func CheckIfEndingTurn(packet_dictionary : Dictionary):
	print("checking if ending turn ...")
	var ending_turn = true
	var handing_turn_over = true
	var sequence_empty = false
	var user_has_won_with_socket = -1
	user_has_won_with_socket = CheckIfUserHasWon()
	if active_shooter_socket_target == active_shooter_socket_self && active_shooter_shell == "blank": ending_turn = false; handing_turn_over = false
	if active_shooter_sequence_length_after_eject == 0: ending_turn = true; sequence_empty = true
	if user_has_won_with_socket != -1: ending_turn = true
	if !packet_dictionary.ending_turn_after_shot:
		properties.FreeLookCameraForUser_Enable()
		GlobalVariables.cursor_state_after_toggle = true
		cursor.SetCursor(true, true)
		properties.permissions.SetMainPermission(true)
		properties.SetTurnControllerPrompts(true)
		#intbranch_shotgun.interactionAllowed = true
		#properties.permissions.SetItemPermissions(true)
	else:
		if (GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID) or GlobalVariables.mp_debugging:
			print(properties.user_name, " is the host. running user end turn routine")
			intermediary.roundManager.UserEndTurn_Packet(active_shooter_socket_self, handing_turn_over, sequence_empty, user_has_won_with_socket)

func ShootingOutcome():
	await get_tree().create_timer(.1, false).timeout
	var sequence = intermediary.game_state.MAIN_active_sequence_dict.sequence_in_shotgun
	var current_shell = sequence[0]
	if sequence.size() == 1: for property in intermediary.instance_handler.instance_property_array: property.running_fast_revival = true
	
	if current_shell == "live":
		PlaySound_LiveFire()
		anim_light_muzzle.play("flash")
		MuzzleFlashPlane()
		intermediary.anim_pp_muzzle_flash.play("pp muzzle flash")
		if !properties.is_active: anim_recoil_thirdperson.play("recoil third person")
		else: anim_recoil_firstperson.play("recoil first person")
		if properties.is_active: cam_shaker.Shake()
		for property in properties.intermediary.instance_handler.instance_property_array:
			if property.socket_number == active_shooter_socket_target:
				property.cam_shaker.Shake()
				break
		anim_muzzle_cone.play("flash cone")
		SmokeParticles()
		BloodParticles()
	else: PlaySound_BlankFire()
	
	if current_shell == "live":
		properties.stat_damage_dealt += active_shooter_shotgun_damage
	if current_shell == "live" && active_shooter_socket_target == active_shooter_socket_self:
		properties.stat_number_of_times_shot_self_with_live += 1
	
	if current_shell == "live" && active_shooter_socket_target == active_shooter_socket_self:
		if properties.is_active:
			animator_shotgun.play("RESET")
			properties.oscillator_manager.LerpToOriginal("shotgun")
			ShotgunBarrel_Grow()
		else: 
			animator_shotgun_thirdperson.play("user shoot self transition_live thirdperson")
			FailsafeAfterSelfShot()
	if current_shell == "blank" && active_shooter_socket_target == active_shooter_socket_self:
		if properties.is_active: 
			PlaySound_ShotgunFoley(true, "transition")
			animator_shotgun.play("user shoot self transition_blank")
		else:
			PlaySound_ShotgunFoley(false, "transition")
			animator_shotgun_thirdperson.play("user shoot self transition_blank thirdperson")
	
	if current_shell == "live":
		for instance in intermediary.instance_handler.instance_property_array:
			if instance.socket_number == active_shooter_socket_target:
				print("death request on instance: ", instance.user_name)
				instance.health_current -= active_shooter_shotgun_damage
				if instance.health_current < 0: 
					instance.health_current = 0
				var dir = GetDirection(instance.socket_number, active_shooter_socket_self)
				instance.death.DeathRequest(dir)
	
	RemoveFirstShellFromSequence()
	
	CheckIfFinalShot()

func CheckIfFinalShot():
	var num_of_users_alive = 0
	for property in intermediary.instance_handler.instance_property_array:
		if property.health_current != 0:
			num_of_users_alive += 1
	if num_of_users_alive == 1:
		print("final shot. fade out music")
		intermediary.music_manager.EndTrack_FadeOut()
		if GlobalVariables.debug_round_index_to_end_game_at == intermediary.game_state.MAIN_active_round_index:
			print("final shot on last round. fade in outro track and cut ambience")
			intermediary.music_manager.FadeInOutroTrack()
			intermediary.music_manager.StopSpeakersAfterFinalShot()
			if intermediary.game_state.MAIN_active_environmental_event == "ice machine":
				intermediary.environmental_event.StopIceMachine()

func PlaySound_BlankFire():
	var rand = randi_range(0, sounds_blank.size() - 1)
	speaker_blank.stream = sounds_blank[rand]
	speaker_blank.play()

func PlaySound_LiveFire():
	var rand = randi_range(0, sounds_live.size() - 1)
	speaker_live.stream = sounds_live[rand]
	speaker_live.play()

func MuzzleFlashPlane():
	muzzle_flash_plane.visible = true
	await get_tree().create_timer(0.05, false).timeout
	muzzle_flash_plane.visible = false

func FailsafeAfterSelfShot():
	await get_tree().create_timer(.4, false).timeout
	SetShotgunTransparency_Global(1, true)
	SetShotgunVisible_Global(true)
	SetShotgunVisible_Local(false)
	ShotgunBarrel_Grow()
	FadeInShotgun_Global()

func RemoveFirstShellFromSequence():
	var sequence = intermediary.game_state.MAIN_active_sequence_dict.sequence_in_shotgun
	intermediary.game_state.MAIN_shell_visible_to_eject = sequence[0]
	sequence.remove_at(0)

func ShotgunBarrel_Remove():
	globalparent_shotgun_cut_segment.visible = false
	localparent_shotgun_cut_segment.visible = false
	globalanimator_cut_segment.play("barrel remove")
	localanimator_cut_segment.play("barrel remove local")
	intermediary.game_state.MAIN_barrel_sawed_off = true

func ShotgunBarrel_Grow():
	if !intermediary.game_state.MAIN_barrel_sawed_off: return
	speaker_barrelgrow.play()
	globalparent_shotgun_cut_segment.visible = true
	localparent_shotgun_cut_segment.visible = true
	globalanimator_cut_segment.play("barrel grow")
	localanimator_cut_segment.play("barrel grow local")
	intermediary.game_state.MAIN_barrel_sawed_off = false

func CheckIfUserHasWon():
	var num_of_users_alive = 0
	var user_alive_socket = -1
	var user_alive_name = ""
	var winning_socket = -1
	for i in intermediary.instance_handler.instance_property_array:
		if i.health_current != 0:
			num_of_users_alive += 1
			user_alive_socket = i.socket_number
			user_alive_name = i.user_name
	if num_of_users_alive == 1: 
		winning_socket = user_alive_socket
		print("---------------------------------------")
		print("---------------------------------------")
		print(str(user_alive_name) + " HAS WON THE GAME!")
		print("---------------------------------------")
		print("---------------------------------------")
	return winning_socket

func SetShotgunVisible_Global(setting_visible : bool):
	globalparent_shotgun_main.visible = setting_visible
	globalparent_shotgun_forestock.visible = setting_visible

func SetShotgunVisible_Local(setting_visible : bool):
	localparent_shotgun.visible = setting_visible

func SetShotgunTransparency_Global(transparency : float, casting_shadows : bool):
	globalparent_shotgun_main.transparency = transparency
	globalparent_shotgun_forestock.transparency = transparency
	globalparent_shotgun_window.transparency = transparency
	globalparent_shotgun_cut_segment_mesh.transparency = transparency
	globalparent_shotgun_main.cast_shadow = casting_shadows
	globalparent_shotgun_forestock.cast_shadow = casting_shadows
	globalparent_shotgun_window.cast_shadow = casting_shadows
	globalparent_shotgun_cut_segment_mesh.cast_shadow = casting_shadows

func FadeInShotgun_Global():
	speaker_bodygrow.play()
	start_transparency = 1
	end_transparency = 0
	elapsed_transparency = 0
	lerping_transparency = true
	await get_tree().create_timer(dur_transparency, false).timeout
	lerping_transparency = false
	SetShotgunTransparency_Global(0, true)

var dur_transparency = .5
var lerping_transparency = false
var elapsed_transparency = 0
var start_transparency = 0
var end_transparency = 0
func Lerp_ShotgunTransparency():
	if lerping_transparency:
		elapsed_transparency += get_process_delta_time()
		var c = clampf(elapsed_transparency / dur_transparency, 0.0, 1.0)
		var val = lerp(start_transparency, end_transparency, c)
		globalparent_shotgun_main.transparency = val
		globalparent_shotgun_forestock.transparency = val
		globalparent_shotgun_window.transparency = val
		globalparent_shotgun_cut_segment_mesh.transparency = val

func IgnoringPacket(packet_dictionary : Dictionary = {}):
	var sent_from = packet_dictionary.sent_from_socket
	if (sent_from == properties.socket_number) && properties.is_active: return true
	if (sent_from != properties.socket_number): return true
	return false

func GetDirection(self_socket, selected_socket):
	var direction = ""
	match self_socket:
		0:
			match selected_socket:
				0: direction = "self"
				1: direction = "left"
				2: direction = "forward"
				3: direction = "right"
		1:
			match selected_socket:
				0: direction = "right"
				1: direction = "self"
				2: direction = "left"
				3: direction = "forward"
		2:
			match selected_socket:
				0: direction = "forward"
				1: direction = "right"
				2: direction = "self"
				3: direction = "left"
		3:
			match selected_socket:
				0: direction = "left"
				1: direction = "forward"
				2: direction = "right"
				3: direction = "self"
	return direction
