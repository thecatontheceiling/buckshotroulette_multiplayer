class_name MP_Jammer extends Node

@export var properties : MP_UserInstanceProperties
@export var button_intbranches : Array[MP_InteractionBranch]
@export var button_colliders : Array[CollisionShape3D]

@export var ui_selected_username : Label3D
@export var bootup_text_array : Array[Node3D]
@export var blinker_array : Array[MeshInstance3D]

@export var bp_jammer : Control
@export var btn_jammer_left : Button

@export var screen_blank : Texture2D
@export var screen_frame : Texture2D
@export var screen_tracker : Texture2D
@export var screen_gridbootup1 : Texture2D
@export var screen_idle : Texture2D
@export var screen_left : Texture2D
@export var screen_right : Texture2D
@export var screen_forward : Texture2D

@export var mat_screen : StandardMaterial3D
@export var mat_blinker_green : StandardMaterial3D
@export var mat_blinker_red : StandardMaterial3D
@export var mat_blinker_void : StandardMaterial3D

@export var speaker_fp_jammer_key_press : AudioStreamPlayer2D
@export var speaker_fp_jammer_bootup_idle : AudioStreamPlayer2D
@export var speaker_tp_jammer_bootup_idle : AudioStreamPlayer3D
@export var speaker_tp_jammer_pressing_idle : AudioStreamPlayer3D
@export var speaker_fp_jammer_beep_single : AudioStreamPlayer2D

@export var speaker_error : AudioStreamPlayer3D
@export var speaker_add_health : AudioStreamPlayer3D
@export var sounds_error : Array[AudioStream]

#whether or not a user is seated on these parts
#						left, forward, right
var valid_target_array = [false, false, false]
var target_direction_strings = ["left", "forward", "right"]
var empty_text = ". . . . . . . ."

func _ready():
	for i in bootup_text_array:
		i.visible = false
	for i in button_colliders:
		i.disabled = true
	for i in button_intbranches:
		i.interactionAllowed = false

var flicker_delay = .08
func Jammer_Enable():
	properties.is_jammed = true
	properties.jammer_checked = false
	properties.health_counter.DisableDisplay()
	PlaySound_RandomError()

func Jammer_Disable():
	if !properties.is_jammed: return
	speaker_add_health.play()
	properties.is_jammed = false
	for i in 2:
		properties.health_counter.EnableDisplay()
		await get_tree().create_timer(flicker_delay, false).timeout
		properties.health_counter.DisableDisplay()
		await get_tree().create_timer(flicker_delay, false).timeout
	properties.health_counter.EnableDisplay()

func Jammer_Check():
	properties.jammer_checked = true
	PlaySound_RandomError()
	for i in 3:
		properties.health_counter.EnableDisplay()
		await get_tree().create_timer(flicker_delay, false).timeout
		properties.health_counter.DisableDisplay()
		await get_tree().create_timer(flicker_delay, false).timeout

func PlaySound_RandomError():
	speaker_error.stream = sounds_error[randi_range(0, sounds_error.size() - 1)]
	speaker_error.play()
	await get_tree().create_timer(.1, false).timeout
	speaker_error.stream = sounds_error[randi_range(0, sounds_error.size() - 1)]
	speaker_error.play()

var previous_input = ""
var selected_target_index = -1
var selected_target_is_valid = false
func GetInput(alias : String):
	var input_index
	if alias != "confirm":
		if previous_input == alias:
			Reset()
			return
	match alias:
		"left":
			input_index = 0
			selected_target_index = input_index
			SetBlinkerState(input_index, true)
			SetUsername(alias, input_index)
			mat_screen.albedo_texture = screen_left
		"forward":
			input_index = 1
			selected_target_index = input_index
			SetBlinkerState(input_index, true)
			SetUsername(alias, input_index)
			mat_screen.albedo_texture = screen_forward
		"right":
			input_index = 2
			selected_target_index = input_index
			SetBlinkerState(input_index, true)
			SetUsername(alias, input_index)
			mat_screen.albedo_texture = screen_right
		"confirm":
			ConfirmButton()
	previous_input = alias
	speaker_fp_jammer_key_press.play()

func Reset():
	mat_screen.albedo_texture = screen_idle
	selected_target_index = -1
	selected_target_is_valid = false
	previous_input = ""
	ui_selected_username.text = ""
	blinker_array[3].set_surface_override_material(0, mat_blinker_red)
	ResetDirectionBlinkers()

func ResetDirectionBlinkers():
	blinker_array[0].set_surface_override_material(0, mat_blinker_void)
	blinker_array[1].set_surface_override_material(0, mat_blinker_void)
	blinker_array[2].set_surface_override_material(0, mat_blinker_void)

func SetUsername(direction : String, index : int):
	var user_name = ""
	if valid_target_array[index]:
		user_name = properties.GetSocketProperties(properties.GetSocketFromDirection(properties.socket_number, direction)).user_name
	ui_selected_username.text = user_name.left(10) + " ..."

func SetBlinkerState(index : int, resetting : bool):
	if resetting: ResetDirectionBlinkers()
	var is_valid = valid_target_array[index]
	for i in range(blinker_array.size()):
		if i == index:
			if is_valid:
				blinker_array[i].set_surface_override_material(0, mat_blinker_green)
			else:
				blinker_array[i].set_surface_override_material(0, mat_blinker_red)
			break
	if is_valid:
		blinker_array[3].set_surface_override_material(0, mat_blinker_green)
	else:
		blinker_array[3].set_surface_override_material(0, mat_blinker_red)
	selected_target_is_valid = is_valid

func ConfirmButton():
	properties.is_on_jammer_selection = false
	if !selected_target_is_valid: 
		return

	for i in button_colliders:
		i.disabled = true
	for i in button_intbranches:
		i.interactionAllowed = false
	properties.permissions.SetMainPermission(false)
	SetJammerControllerPrompts(false)
	await get_tree().create_timer(.05, false).timeout
	var direction = target_direction_strings[selected_target_index]
	var instance_property_to_jam : MP_UserInstanceProperties = properties.GetSocketProperties(properties.GetSocketFromDirection(properties.socket_number, direction))
	var selected_socket_number : int = properties.GetSocketFromDirection(properties.socket_number, direction)
	looping = true
	ShowFinalTargetOnScreen(direction)
	await get_tree().create_timer(1.5, false).timeout
	var secondary_item_interaction_request_dictionary = {
		"item_id": 3,
		"item_selected_socket_number": selected_socket_number
	}
	properties.item_interaction.InteractWIthItemRequest_Secondary(secondary_item_interaction_request_dictionary)

var looping = false
func ShowFinalTargetOnScreen(for_direction : String):
	var screen_active
	match for_direction:
		"left": screen_active = screen_left
		"forward": screen_active = screen_forward
		"right": screen_active = screen_right
	for blinker in blinker_array:
			blinker.set_surface_override_material(0, mat_blinker_green)
	await get_tree().create_timer(.64, false).timeout
	var am =  0
	while looping:
		if am < 7: speaker_fp_jammer_beep_single.play()
		am += 1
		mat_screen.albedo_texture = screen_idle
		for blinker in blinker_array:
			blinker.set_surface_override_material(0, mat_blinker_void)
		await get_tree().create_timer(.1, false).timeout
		if am < 7: speaker_fp_jammer_beep_single.play()
		am += 1
		mat_screen.albedo_texture = screen_active
		for blinker in blinker_array:
			blinker.set_surface_override_material(0, mat_blinker_green)
		await get_tree().create_timer(.1, false).timeout
		pass
	pass

func SetValidTargets():
	var eligible_property_array = []
	valid_target_array = [false, false, false]
	var socket_eligible_by_index = [false, false, false , false]
	for instance_property in properties.intermediary.instance_handler.instance_property_array:
		if instance_property.socket_number != properties.socket_number:
			if !instance_property.is_jammed && instance_property.health_current != 0:
				socket_eligible_by_index[instance_property.socket_number] = true
				eligible_property_array.append(instance_property)
	for eligible_property in eligible_property_array:
		var dir = properties.GetDirection(properties.socket_number, eligible_property.socket_number)
		match dir:
			"left": valid_target_array[0] = true
			"forward": valid_target_array[1] = true
			"right": valid_target_array[2] = true

func BootupFinished():
	SetValidTargets()
	GlobalVariables.cursor_state_after_toggle = true
	properties.permissions.cursor.SetCursor(true, true)
	properties.is_on_jammer_selection = true
	SetJammerControllerPrompts(true)

func SetJammerControllerPrompts(state : bool):
	if state:
		bp_jammer.visible = true
		if properties.cursor.controller_active: btn_jammer_left.grab_focus()
		properties.controller.previousFocus = btn_jammer_left
	else:
		bp_jammer.visible = false

func BootupJammer():
	ui_selected_username.text = ""
	previous_input = ""
	selected_target_index = -1
	selected_target_is_valid = false
	mat_screen.albedo_texture = screen_blank
	for i in button_colliders:
		i.disabled = false
	for i in button_intbranches:
		i.interactionAllowed = true
	await get_tree().create_timer(.4, false).timeout
	mat_screen.albedo_texture = screen_frame
	speaker_fp_jammer_bootup_idle.play()
	await get_tree().create_timer(.5, false).timeout
	for i in range(bootup_text_array.size()):
		bootup_text_array[i].visible = true
		if i == 8:
			ui_selected_username.text = empty_text
			await get_tree().create_timer(.1, false).timeout
			ui_selected_username.text = ""
		await get_tree().create_timer(.02, false).timeout
	await get_tree().create_timer(.2, false).timeout
	for i in bootup_text_array:
		i.visible = false
	for blinker in blinker_array:
		blinker.set_surface_override_material(0, mat_blinker_green)
	await get_tree().create_timer(.4, false).timeout
	mat_screen.albedo_texture = screen_tracker
	await get_tree().create_timer(.1, false).timeout
	mat_screen.albedo_texture = screen_gridbootup1
	ui_selected_username.text = empty_text
	await get_tree().create_timer(.1, false).timeout
	ui_selected_username.text = ""
	mat_screen.albedo_texture = screen_idle
	for blinker in blinker_array:
		blinker.set_surface_override_material(0, mat_blinker_void)
	blinker_array[3].set_surface_override_material(0, mat_blinker_red)
	BootupFinished()































