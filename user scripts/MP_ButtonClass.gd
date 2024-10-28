class_name MP_ButtonClass extends Node

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
	if properties.is_active:
		print("set ui control on user: ", properties.user_name)
		ui_control = get_parent()
		get_parent().connect("focus_entered", OnHover)
		get_parent().connect("focus_exited", OnExit)
		get_parent().connect("mouse_entered", OnHover)
		get_parent().connect("mouse_exited", OnExit)
		get_parent().connect("pressed", OnPress)
		if (isDynamic): ui.modulate.a = ui_opacity_inactive
		await get_tree().create_timer(3, false).timeout
	print("properties is active: ", properties.is_active)

func _process(delta):
	#if properties.is_active: print("cursor on ui: ", cursor.on_ui)
	pass

func SetFilter(alias : String):
	match(alias):
		"ignore":
			ui_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		"stop":
			ui_control.mouse_filter = Control.MOUSE_FILTER_STOP

func OnHover():
	print("hover")
	if (isActive && mainActive):
		print("properties active on hover: ", properties.is_active, " with name: ", properties.user_name)
		if properties.is_active: print("set true"); cursor.on_ui = true
		if (isDynamic):
			if (playing_sound):
				speaker_hover.pitch_scale = randf_range(.95, 1.0)
				speaker_hover.play()
			ui.modulate.a = ui_opacity_active
		cursor.SetCursorImage("hover")

func OnExit():
	print("exit")
	if properties.is_active: print("set false"); cursor.on_ui = false
	if (isActive && mainActive):
		if (isDynamic):
			ui.modulate.a = ui_opacity_inactive
		cursor.SetCursorImage("point")

signal is_pressed
func OnPress():
	if (isActive && mainActive):
		emit_signal("is_pressed")
