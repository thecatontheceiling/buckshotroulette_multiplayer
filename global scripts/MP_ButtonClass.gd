class_name MP_ButtonClass2 extends Node

@export var properties : MP_UserInstanceProperties
@export var cursor : MP_CursorManager
@export var alias : String
@export var playing_sound : bool
@export var isActive : bool
@export var isDynamic : bool
@export var ui : CanvasItem
@export var ui_control : Control
@export var speaker_press : AudioStreamPlayer2D
@export var speaker_hover : AudioStreamPlayer2D
@export var ui_opacity_inactive : float = 1
@export var ui_opacity_active : float = .78
@export var resetting : bool
var mainActive = true

func _ready():
	ui_control = get_parent()
	get_parent().connect("focus_entered", OnHover)
	get_parent().connect("focus_exited", OnExit)
	get_parent().connect("mouse_entered", OnHover)
	get_parent().connect("mouse_exited", OnExit)
	get_parent().connect("pressed", OnPress)
	if (isDynamic): ui.modulate.a = ui_opacity_inactive

func SetFilter(alias : String):
	if properties.is_active:
		match(alias):
			"ignore":
				ui_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
			"stop":
				ui_control.mouse_filter = Control.MOUSE_FILTER_STOP

func OnHover():
	if properties.is_active:
		print("on hover")
		if (isActive && mainActive):
			if (isDynamic):
				if (playing_sound):
					speaker_hover.pitch_scale = randf_range(.95, 1.0)
					speaker_hover.play()
				ui.modulate.a = ui_opacity_active
			cursor.SetCursorImage("hover")

func OnExit():
	if properties.is_active:
		if (isActive && mainActive):
			if (isDynamic):
				ui.modulate.a = ui_opacity_inactive
			cursor.SetCursorImage("point")

signal is_pressed
func OnPress():
	if properties.is_active:
		if (isActive && mainActive):
			emit_signal("is_pressed")
