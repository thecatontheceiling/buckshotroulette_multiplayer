class_name MP_HealthCounter extends Node

@export var properties : MP_UserInstanceProperties
@export var cam : MP_CameraManager
var intermed : MP_InteractionIntermed

@export var ui_main_parent : Node3D
@export var ui_divider1 : Node3D
@export var ui_divider2 : Node3D
@export var animator_dividers : AnimationPlayer
@export var animator_selector : AnimationPlayer
@export var ui_led_parent: Node3D
@export var ui_charge_array : Array[Node3D]
@export var ui_charge_array_temp : Array[Node3D] #replace with diegetic display
@export var ui_charge_array_side_left : Array[Node3D]
@export var ui_charge_array_side_right : Array[Node3D]
@export var charge_to_blink_vertical : Node3D
@export var charge_to_blink_horizontal : Node3D
@export var charge_blink_delay : float

@export var ui_round_indicator_base : Node3D
@export var ui_round_indicator_selector : Node3D
@export var pos_array_rounds : Array[Node3D]

@export var ui_parent_winner : Node3D
@export var animator_winner : AnimationPlayer

@export var speaker_horizontal_line_bootup : AudioStreamPlayer2D
@export var speaker_round_indicator_wave : AudioStreamPlayer2D
@export var speaker_round_indicator_hum : AudioStreamPlayer2D
@export var speaker_shutdown : AudioStreamPlayer2D
@export var speaker_health_bootup : AudioStreamPlayer3D
@export var speaker_reduce_health : AudioStreamPlayer3D
@export var speaker_space : AudioStreamPlayer2D
@export var speaker_increase_health : AudioStreamPlayer3D

func _ready():
	intermed = properties.intermediary
	ClearDisplay()

func BootupDisplay_ShowCurrentRound():
	cam.BeginLerp("health counter")
	await get_tree().create_timer(.4, false).timeout
	var current_round = intermed.game_state.MAIN_active_round_index
	if current_round <= 2:
		ui_round_indicator_selector.transform.origin = pos_array_rounds[current_round].transform.origin
	ClearDisplay()
	await get_tree().create_timer(.2, false).timeout
	if properties.is_active: speaker_round_indicator_hum.play()
	ui_round_indicator_base.visible = true
	await get_tree().create_timer(.6, false).timeout
	if properties.is_active: 
		animator_selector.play("loop")
		if intermed.game_state.MAIN_active_round_index != 0:
			intermed.music_manager.LoadTrack(intermed.game_state.MAIN_active_round_index, false, true)
	ui_round_indicator_selector.visible = true
	await get_tree().create_timer(1.4, false).timeout
	if properties.is_active: speaker_round_indicator_hum.stop()
	ClearDisplay()
	if properties.is_active: speaker_space.play()
	await get_tree().create_timer(.3, false).timeout

func BootupDisplay_Health():
	cam.BeginLerp("health counter")
	await get_tree().create_timer(.4, false).timeout
	if properties.is_active: speaker_space.stop()
	if properties.is_active: speaker_horizontal_line_bootup.play()
	ui_led_parent.visible = true
	#await get_tree().create_timer(.4, false).timeout
	ui_divider1.visible = true; ui_divider2.visible = true
	animator_dividers.play("show")
	await get_tree().create_timer(.5, false).timeout
	if properties.is_active: speaker_horizontal_line_bootup.stop()
	var starting_health = intermed.game_state.MAIN_active_round_dict.starting_health
	properties.health_current = starting_health
	prev_health = properties.health_current
	properties.health_on_round_start = starting_health
	CancelBlink()
	for i in range(starting_health):
		ui_charge_array[i].visible = true
		ui_charge_array_temp[i].visible = true
	if properties.is_active: speaker_health_bootup.play()
	await get_tree().create_timer(.1, false).timeout
	intermed.game_state.turn_order.StartIndicator(intermed.game_state.MAIN_active_turn_order)
	await get_tree().create_timer(.5, false).timeout

var blinking_last_charge = false
func BlinkLastCharge():
	while blinking_last_charge:
		if blinking_last_charge:
			charge_to_blink_horizontal.visible = true
			charge_to_blink_vertical.visible = true
		await get_tree().create_timer(charge_blink_delay, false).timeout
		if blinking_last_charge:
			charge_to_blink_horizontal.visible = false
			charge_to_blink_vertical.visible = false
		await get_tree().create_timer(charge_blink_delay, false).timeout
		pass
	pass

func StartBlink():
	blinking_last_charge = true
	BlinkLastCharge()

func CancelBlink():
	blinking_last_charge = false
	charge_to_blink_horizontal.visible = true
	charge_to_blink_vertical.visible = true

var prev_health
var healing_health = false
func UpdateDisplay():
	var health = properties.health_current
	
	if health < prev_health && !properties.is_active:
		speaker_reduce_health.play()
	
	if healing_health:
		speaker_increase_health.play()
		healing_health = false
	
	if health == 1:
		StartBlink()
	if health == 0 or health != 1:
		CancelBlink()
	
	prev_health = health
	if health == 0: 
		clearing_turn_order = false
		ClearDisplay()
		clearing_turn_order = true
		return
	
	for i in ui_charge_array: i.visible = false
	for i in ui_charge_array_temp: i.visible = false
	for i in range(health):
		ui_charge_array[i].visible = true
		ui_charge_array_temp[i].visible = true
	print("updated health display with value: ", health)

var clearing_turn_order = true
var fs = false
func ClearDisplay():
	if !ui_round_indicator_base.visible && properties.is_active:
		if fs: 
			speaker_shutdown.play()
	fs = true
	if clearing_turn_order: intermed.game_state.turn_order.parent.visible = false
	ui_parent_winner.visible = false
	for i in ui_charge_array: i.visible = false
	for i in ui_charge_array_temp: i.visible = false
	ui_round_indicator_base.visible = false
	ui_round_indicator_selector.visible = false
	ui_divider1.visible = false; ui_divider2.visible = false
	ui_led_parent.visible = false
	animator_dividers.play("RESET")
	animator_selector.play("RESET")

func DisableDisplay():
	ui_main_parent.visible = false

func EnableDisplay():
	ui_main_parent.visible = true

func ClearDisplay_Charges():
	for i in ui_charge_array: i.visible = false
	for i in ui_charge_array_temp: i.visible = false

func ShowWinState():
	ui_parent_winner.visible = true
	animator_winner.play("loop")








