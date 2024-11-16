class_name MP_ButtonClassMain extends Node

@export var alias : String
@export var sub_alias : String
@export var is_lobby_scene : bool
@export var ui_element_to_affect : CanvasItem
@export var ui_element_to_affect_hover_transparency : float
@export var set_opacity_to_default_on_press : bool = true
@export var checking_held_input : bool
@export var playing_sound_elsewhere : bool
@export_group("mouse emulation")
@export var interaction_manager : MP_InteractionManager
@export var is_emulating_mouse_in_main : bool
@export var overridingMouseRaycast : bool
@export var mouseRaycast : MP_MouseRaycast
@export var mouseRaycastVector : Vector2
@export var is3D : bool
@export var ui_3D : Control
@export var ui : Control
@export var ui_opacity_active : float
@export var ui_opacity_inactive : float
@export var is_active : bool
@export_group("user info segment")
@export var segment : MP_UserInfoSegment
@export_group("mp_lobby.tscn")
@export var cursor : MP_CursorManager
@export var speaker_button_press : AudioStreamPlayer2D
@export var speaker_button_hover : AudioStreamPlayer2D
@export var lobby_manager : LobbyManager
@export var dont_set_cursor_to_point_after_press : bool
@export var separated_from_lobby_scene : bool
@export var is_related_to_customization : bool
@export var right_click_enabled : bool
@export var mouse_wheel_enabled : bool
var button : Button
var intermediary : MP_InteractionIntermed
var active_speaker_hover : AudioStreamPlayer2D
var active_speaker_press : AudioStreamPlayer2D
var active_cursor_manager : MP_CursorManager
@export var match_customization : MP_MatchCustomization
@export var alias_right_click : String
@export var alias_scroll_down : String
@export var alias_scroll_up : String

func _ready():
	button = get_parent()
	if !is_lobby_scene: 
		intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")
	else:
		if !separated_from_lobby_scene:
			active_speaker_press = speaker_button_press
			active_speaker_hover = speaker_button_hover
			active_cursor_manager = cursor
		else:
			var intermed = get_node("/root/mp_lobby/standalone managers/lobby ui")
			match_customization = get_node("/root/mp_lobby/standalone managers/match customization")
			active_speaker_press = intermed.speaker_button_press
			active_speaker_hover = intermed.speaker_button_hover
			lobby_manager = intermed.lobby_manager
			active_cursor_manager = intermed.cursor
	get_parent().connect("focus_entered", OnMouseEnter)
	get_parent().connect("focus_exited", OnMouseExit)
	if !is_emulating_mouse_in_main: button.connect("mouse_entered", OnMouseEnter)
	if !is_emulating_mouse_in_main: button.connect("mouse_exited", OnMouseExit)
	button.connect("pressed", OnPress)
	button.connect("button_down", OnButtonDown)
	button.connect("button_up", OnButtonUp)

func _process(delta):
	if !is_lobby_scene:
		SetupInMainScene()
	if cursor != null:
		if cursor.disable_buttons_when_cursor_hidden:
			SetMouseInput(cursor.cursor_visible)
	checking_hold = held
	if checking_hold && checking_held_input:
		CheckHold()

var fs = false
func SetupInMainScene():
	if !fs:
		if intermediary.intermed_properties != null:
			active_speaker_press = intermediary.speaker_button_press
			active_speaker_hover = intermediary.speaker_button_hover
			active_cursor_manager = intermediary.intermed_properties.cursor
			fs = true

func SetMouseInput(state : bool):
	if state:
		button.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func OnPress():
	if is_emulating_mouse_in_main:
		interaction_manager.MainInteractionEvent()
		return
	if !dont_set_cursor_to_point_after_press: active_cursor_manager.SetCursorImage("point")
	if !playing_sound_elsewhere: active_speaker_press.play()
	if ui_element_to_affect != null:
		if set_opacity_to_default_on_press:
			ui_element_to_affect.modulate.a = 1
	if !is_lobby_scene: 
		intermediary.InteractionPipe(alias, self)
	else:
		if !is_related_to_customization:
			lobby_manager.Pipe(alias, sub_alias)
		else:
			match_customization.Pipe(get_child(0).alias, get_child(0))

func OnRightClick():
	if right_click_enabled:
		if !dont_set_cursor_to_point_after_press: active_cursor_manager.SetCursorImage("point")
		if !playing_sound_elsewhere:
			active_speaker_press.play()
		if ui_element_to_affect != null:
			if set_opacity_to_default_on_press:
				ui_element_to_affect.modulate.a = 1
		match_customization.Pipe(get_child(0).alias_right_click, get_child(0))

var held = false
func OnButtonDown():
	fs_up = false
	held = true

func OnButtonUp():
	if !fs_up:
		StopButtonHold_MainInput()
		fs_check = false
		fs_up = true
	held = false

var t = 0.0
var threshold = 0.3
var checking_hold = false
var fs_check = false
var fs_up = false
func CheckHold():
	if checking_hold:
		t += get_process_delta_time()
	if t > threshold && !fs_check:
		if !GlobalVariables.looping_input_secondary:
			StartButtonHold_MainInput()
			fs_check = true

func StartButtonHold_MainInput():
	GlobalVariables.looping_input_main = true
	looping_input = true
	LoopInput()

func StopButtonHold_MainInput():
	GlobalVariables.looping_input_main = false
	looping_input = false
	t = 0

var looping_input = false
var input_loop_delay = .06
func LoopInput():
	while looping_input:
		OnPress()
		await get_tree().create_timer(input_loop_delay, false).timeout
		pass
	pass

func OnMouseWheelUp():
	if mouse_wheel_enabled:
		if !playing_sound_elsewhere:
			active_speaker_press.play()
		match_customization.Pipe(get_child(0).alias_scroll_up, get_child(0))

func OnMouseWheelDown():
	if mouse_wheel_enabled:
		if !playing_sound_elsewhere:
			active_speaker_press.play()
		match_customization.Pipe(get_child(0).alias_scroll_down, get_child(0))

func SetUI(state : bool):
		if (state):
			if (!is3D): 
				if ui != null:
					ui.modulate.a = ui_opacity_active
			else: ui_3D.visible = true
		else:
			if (!is3D): 
				if ui != null:
					ui.modulate.a = ui_opacity_inactive
			else: ui_3D.visible = false

func OnMouseEnter():
	GlobalVariables.current_button_hovered_over = button
	if is_emulating_mouse_in_main:
		SetUI(true)
		if (overridingMouseRaycast):
			mouseRaycast.GetRaycastOverride(mouseRaycastVector)
		return
	active_cursor_manager.SetCursorImage("hover")
	if ui_element_to_affect != null:
		ui_element_to_affect.modulate.a = ui_element_to_affect_hover_transparency
	active_speaker_hover.play()

func OnMouseExit():
	GlobalVariables.current_button_hovered_over = null
	if is_emulating_mouse_in_main:
		SetUI(false)
	if ui_element_to_affect != null:
		ui_element_to_affect.modulate.a = 1
	active_cursor_manager.SetCursorImage("point")
