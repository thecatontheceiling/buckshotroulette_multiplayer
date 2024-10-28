class_name MP_ButtonClassMain extends Node

@export var alias : String
@export var sub_alias : String
@export var is_lobby_scene : bool
@export var ui_element_to_affect : CanvasItem
@export var ui_element_to_affect_hover_transparency : float
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
var button : Button
var intermediary : MP_InteractionIntermed
var active_speaker_hover : AudioStreamPlayer2D
var active_speaker_press : AudioStreamPlayer2D
var active_cursor_manager : MP_CursorManager

func _ready():
	button = get_parent()
	if !is_lobby_scene: 
		intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")
	else:
		active_speaker_press = speaker_button_press
		active_speaker_hover = speaker_button_hover
		active_cursor_manager = cursor
	get_parent().connect("focus_entered", OnMouseEnter)
	get_parent().connect("focus_exited", OnMouseExit)
	if !is_emulating_mouse_in_main: button.connect("mouse_entered", OnMouseEnter)
	if !is_emulating_mouse_in_main: button.connect("mouse_exited", OnMouseExit)
	button.connect("pressed", OnPress)

func _process(delta):
	if !is_lobby_scene:
		SetupInMainScene()
	if cursor != null:
		if cursor.disable_buttons_when_cursor_hidden:
			SetMouseInput(cursor.cursor_visible)

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
	active_speaker_press.play()
	if ui_element_to_affect != null:
		ui_element_to_affect.modulate.a = 1
	if !is_lobby_scene: 
		intermediary.InteractionPipe(alias, self)
	else:
		lobby_manager.Pipe(alias, sub_alias)

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
	if is_emulating_mouse_in_main:
		SetUI(false)
	if ui_element_to_affect != null:
		ui_element_to_affect.modulate.a = 1
	active_cursor_manager.SetCursorImage("point")
