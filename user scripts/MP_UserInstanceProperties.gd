class_name MP_UserInstanceProperties extends Node

@export var instance_root : Node3D
@export var socket_number : int
@export var user_id : int
@export var user_name : String
@export var cpu_enabled : bool
@export var is_active = false
@export var health_on_round_start : int
@export var health_current : int
@export var jammer_checked : bool
@export var is_jammed : bool
@export var is_spectating : bool
@export var is_stealing_item : bool
@export var is_grabbing_items : bool
@export var is_holding_item_to_place : bool
@export var is_interacting_with_item : bool
@export var is_on_secondary_interaction : bool
@export var is_viewing_jammer : bool
@export var is_holding_shotgun : bool
@export var user_inventory : Array[Dictionary] = [{},{},{},{},{},{},{},{}]
@export var user_inventory_instance_array : Array[Node3D] = [null,null,null,null,null,null,null,null]
@export var user_inventory_count_by_item_id : Array[int]
@export var user_item_resource_array : Array[MP_ItemResource_User] #nvm this crashes the editor LOL
@export_group("item properties (index = ID)")
@export var user_item_array_hand_R : Array[Node3D]
@export var user_item_array_mesh_R : Array[Node3D]
@export var user_item_array_hand_L : Array[Node3D]
@export var user_item_array_mesh_L : Array[Node3D]
@export var user_item_array_offset_y : Array[float]
@export_group("")
@export var num_of_items_currently_grabbed : int

@export_group("user handlers")
@export var cursor : MP_CursorManager
@export var controller : MP_ControllerManager
@export var cam : MP_CameraManager
@export var cam_shaker : MP_CameraShaker
@export var state_manager : MP_UserStateManager
@export var timeout : MP_UserTimeout
@export var hover_pan : MP_HoverPan
@export var description : MP_DescriptionManager
@export var interaction : MP_InteractionManager
@export var shotgun : MP_ShotgunInteraction
@export var shell_ejection : MP_ShellEjection
@export var permissions : MP_UserPermissions
@export var death : MP_DeathManager
@export var health_counter : MP_HealthCounter
@export var hands : MP_HandManager
@export var oscillator_manager : MP_OscillateManager
@export var oscillators : Array[MP_Oscillate]
@export var look_manager : MP_UserLook
@export var particles_shooting : MP_SmokeParticles
@export var item_manager : MP_ItemManager
@export var item_interaction : MP_ItemInteraction
@export var item_stealing : MP_ItemStealing
@export var dialogue : MP_Dialogue
@export var burner_phone : MP_BurnerPhone
@export var jammer_manager : MP_Jammer
@export var briefcase_manager : MP_BriefcaseMachine
@export var viewblocker : MP_Viewblocker
@export var inspection : MP_UserInspection
@export var mouse_raycast : MP_MouseRaycast
@export var customization : MP_UserCustomization
@export var label_itemname : Label
@export var label_itemdesc : Label
@export var animator_winlose : AnimationPlayer
@export var bp_turn : Control
@export var btn_shotgun : Control
@export var bp_adrenaline : Control
@export var btn_adrenaline_first : Control
var intermediary : MP_InteractionIntermed
var debug_index = -1
var original_volume_interaction_bus_db : float
var original_volume_music_bus_db : float
var lerp_bus_elapsed = 0
var lerp_bus_lerping = false
var lerp_bus_duration = 3
var lerp_bus_interaction_start_linear = 0
var lerp_bus_interaction_end_linear = 0
var lerp_bus_music_start_linear = 0
var lerp_bus_music_end_linear = 0
var original_volume_linear_interaction = 0
var original_volume_linear_music = 0

var stat_damage_dealt : int
var stat_number_of_deaths : int
var stat_number_of_cigarettes_smoked : int
var stat_number_of_times_shot_self_with_live : int
var stat_number_of_items_used : int
var stat_amount_of_cash_earned : int

@export_group("debug")
@export var tabletop_blockout : Node3D
@export var shotgun_local_parent : Node3D

func _ready():
	intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")
	original_volume_linear_interaction = db_to_linear(AudioServer.get_bus_volume_db(3))
	original_volume_linear_music = db_to_linear(AudioServer.get_bus_volume_db(1))
	health_current = 100
	CLearInventory_Count()
	SetOscillators()
	Debugging() 

func _process(delta):
	LerpBus()

func _unhandled_input(event):
	if event.is_action_pressed("exit game") && is_active:
		mouse_raycast.SetMouseRaycast(intermediary.ingame_lobby_ui.viewing_ui)
		intermediary.ingame_lobby_ui.ToggleUI()

func PacketSort(dict : Dictionary):
	var value_category = dict.values()[0]
	var value_alias = dict.values()[1]
	match value_alias:
		"pickup shotgun":
			shotgun.ReceivePacket_PickUpShotgun(dict)
		"shoot user":
			shotgun.ReceivePacket_Shoot(dict)
		"look at user":
			look_manager.ReceivePacket_Look(dict)
		"grab item":
			item_manager.ReceivePacket_GrabItem(dict)
		"place item":
			item_manager.ReceivePacket_PlaceItem(dict)
		"interact with item":
			item_interaction.ReceivePacket_InteractWithItem(dict)
		"secondary item interaction":
			item_interaction.ReceivePacket_InteractWithItem_Secondary(dict)
		"timeout exceeded":
			ReceivePacket_TimeoutExceeded(dict)

func SetTurnControllerPrompts(state : bool):
	if state:
		bp_turn.visible = true
		if cursor.controller_active: btn_shotgun.grab_focus()
		controller.previousFocus = btn_shotgun
	else:
		bp_turn.visible = false

func SetAdrenalineControllerPrompts(state : bool):
	if state:
		bp_adrenaline.visible = true
		if cursor.controller_active: btn_adrenaline_first.grab_focus()
		controller.previousFocus = btn_adrenaline_first
	else:
		bp_adrenaline.visible = false

func TransferInventoryToGlobalParent():
	for item in user_inventory_instance_array:
		if item != null:
			var orig = item.global_transform
			item.get_parent().remove_child(item)
			intermediary.item_spawn_global_parent.add_child(item)
			item.global_transform = orig

func CLearInventory_Count():
	user_inventory_count_by_item_id = []
	for i in 50: user_inventory_count_by_item_id.append(0)

func FadeInAudioBus():
	lerp_bus_lerping = false
	lerp_bus_elapsed = 0
	lerp_bus_interaction_start_linear = db_to_linear(AudioServer.get_bus_volume_db(3))
	lerp_bus_interaction_end_linear = original_volume_linear_interaction
	lerp_bus_music_end_linear = db_to_linear(AudioServer.get_bus_volume_db(1))
	lerp_bus_music_end_linear = original_volume_linear_music
	lerp_bus_lerping = true

func FadeOutAudioBus():
	lerp_bus_lerping = false
	lerp_bus_elapsed = 0
	lerp_bus_interaction_start_linear = db_to_linear(AudioServer.get_bus_volume_db(3))
	lerp_bus_interaction_end_linear = 0
	lerp_bus_music_end_linear = db_to_linear(AudioServer.get_bus_volume_db(1))
	lerp_bus_music_end_linear = 0
	lerp_bus_lerping = true

func LerpBus():
	if lerp_bus_lerping:
		lerp_bus_elapsed += get_process_delta_time()
		var c = clampf(lerp_bus_elapsed / lerp_bus_duration, 0.0, 1.0)
		var vol_interaction = lerp(float(lerp_bus_interaction_start_linear), float(lerp_bus_interaction_end_linear), c)
		var vol_music = lerp(float(lerp_bus_music_start_linear), float(lerp_bus_music_end_linear), c)
		AudioServer.set_bus_volume_db(3, linear_to_db(vol_interaction))
		AudioServer.set_bus_volume_db(1, linear_to_db(vol_music))

func MuteAudioOnDeath():
	lerp_bus_lerping = false
	original_volume_interaction_bus_db = AudioServer.get_bus_volume_db(3)
	original_volume_music_bus_db = AudioServer.get_bus_volume_db(1)
	AudioServer.set_bus_volume_db(3, linear_to_db(0))
	AudioServer.set_bus_volume_db(1, linear_to_db(0))

func UnmuteAudioOnRevive():
	lerp_bus_lerping = false
	AudioServer.set_bus_volume_db(3, original_volume_interaction_bus_db)
	AudioServer.set_bus_volume_db(1, original_volume_music_bus_db)

func Debugging():
	tabletop_blockout.visible = false
	shotgun_local_parent.visible = false

func SetOscillators():
	for osc in oscillators:
		osc.SetRandomFrequency()
	oscillator_manager.StartOscillating("hands")
	oscillator_manager.StartOscillating("body")

func PauseOscillation():
	oscillator_manager.StopOscillating("hands")
	oscillator_manager.LerpToOriginal("hands")

func ResumeOscillation():
	oscillator_manager.StartOscillating("hands")

func LookAtSocket(socket_to_look_at : int, slow : bool):
	var direction = GetDirection(socket_number, socket_to_look_at)
	cam.BeginLerp("opponent " + direction, slow)

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

func GetSocketFromDirection(self_socket : int, selected_direction : String):
	var socket_number = 0
	match self_socket:
		0:
			match selected_direction:
				"self": socket_number = 0
				"left": socket_number = 1
				"forward": socket_number = 2
				"right": socket_number = 3
		1:
			match selected_direction:
				"self": socket_number = 1
				"left": socket_number = 2
				"forward": socket_number = 3
				"right": socket_number = 0
		2:
			match selected_direction:
				"self": socket_number = 2
				"left": socket_number = 3
				"forward": socket_number = 0
				"right": socket_number = 1
		3:
			match selected_direction:
				"self": socket_number = 3
				"left": socket_number = 0
				"forward": socket_number = 1
				"right": socket_number = 2
	return socket_number

func GetSocketProperties(socket_number : int):
	for instance_property in intermediary.instance_handler.instance_property_array:
		if instance_property.socket_number == socket_number:
			return instance_property
	return null

func ReceivePacket_TimeoutExceeded(packet : Dictionary):
	print("timeout exceeded with packet: ", packet)
	
	intermediary.game_state.StopTimeoutForSocket(packet.timeout_type, packet.socket_number)
	intermediary.game_state.StopTimeoutForSocket("adrenaline", packet.socket_number)
	intermediary.game_state.StopTimeoutForSocket("jammer", packet.socket_number)
	
	match packet.timeout_type:
		"adrenaline":
			if !packet.ending_turn_after_timeout:
				if socket_number == packet.socket_number:
					cam.BeginLerp("home")
					permissions.SetMainPermission(true)
					SetTurnControllerPrompts(true)
					is_stealing_item = false
					is_on_secondary_interaction = false
				else:
					LookAtSocket(packet.socket_number, true)
			else:
				if socket_number == packet.socket_number:
					permissions.SetMainPermission(false)
					intermediary.roundManager.PassTurn(packet.next_turn_socket)
					is_stealing_item = false
					is_on_secondary_interaction = false
		"jammer":
			if !packet.ending_turn_after_timeout:
				if socket_number == packet.socket_number:
					item_interaction.ReturnJammerAfterTimeout()
					permissions.SetMainPermission(true)
					SetTurnControllerPrompts(true)
					is_on_secondary_interaction = false
			else:
				if socket_number == packet.socket_number:
					item_interaction.ReturnJammerAfterTimeout()
					permissions.SetMainPermission(false)
					is_on_secondary_interaction = false
					intermediary.roundManager.PassTurn(packet.next_turn_socket)
		"item distribution":
			if socket_number == packet.socket_number:
				item_manager.EndItemGrabbingAfterTimeoutä()
		"turn":
			if socket_number == packet.socket_number:
				permissions.SetMainPermission(false)
				intermediary.roundManager.PassTurn(packet.next_turn_socket)
		"shotgun target selection":
			if socket_number == packet.socket_number:
				permissions.SetMainPermission(false)
				shotgun.DropShotgun()
				await get_tree().create_timer(.39, false).timeout
				intermediary.roundManager.PassTurn(packet.next_turn_socket)
