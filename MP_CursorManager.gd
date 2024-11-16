class_name MP_CursorManager extends Node

@export var controller : MP_ControllerManager
@export var properties : MP_UserInstanceProperties
@export var speaker : AudioStreamPlayer2D
@export var cursor_point : CompressedTexture2D
@export var cursor_hover : CompressedTexture2D
@export var cursor_invalid : CompressedTexture2D
@export var cursor_eye : CompressedTexture2D
@export var is_lobby_scene : bool = false
@export var disable_buttons_when_cursor_hidden : bool
var on_ui = false
var cursor_visible = false
var controller_active = false
var checking_options = false
var cursor_visible_after_toggle = false
var previously_visible = false

var setting_previously_visible = true
func SetCursor(isVisible : bool, playSound : bool):
	previously_visible = isVisible
	if !checking_options: cursor_visible_after_toggle = isVisible
	if is_lobby_scene:
		cursor_visible = isVisible
		if (playSound): speaker.play()
		if (isVisible):
			if (!controller_active): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else: Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if (!isVisible):
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		return
	if (properties.is_active):
		if !checking_options:
			cursor_visible = isVisible
		if properties.intermediary.ingame_lobby_ui.viewing_ui && !properties.intermediary.ingame_lobby_ui.ignoring_viewing:
			return
		if properties.camera_look.looking_active:
			return
		if (playSound): speaker.play()
		if (isVisible):
			if (!controller_active): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else: Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			#if !checking_options: cursor_visible = true
		if (!isVisible):
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			#if !checking_options: cursor_visible = false

func SetCursorImage(alias : String):
	if is_lobby_scene:
		match alias:
			"point": Input.set_custom_mouse_cursor(cursor_point, 0, Vector2(12, 0))
			"hover": Input.set_custom_mouse_cursor(cursor_hover, 0, Vector2(9, 0))
			"invalid": Input.set_custom_mouse_cursor(cursor_invalid, 0, Vector2(12, 0))
			"eye": Input.set_custom_mouse_cursor(cursor_eye, 0, Vector2(12, 0))
		return
	if (properties.is_active):
		match(alias):
			"point": Input.set_custom_mouse_cursor(cursor_point, 0, Vector2(12, 0))
			"hover": Input.set_custom_mouse_cursor(cursor_hover, 0, Vector2(9, 0))
			"invalid": Input.set_custom_mouse_cursor(cursor_invalid, 0, Vector2(12, 0))
			"eye": Input.set_custom_mouse_cursor(cursor_eye, 0, Vector2(12, 0))
