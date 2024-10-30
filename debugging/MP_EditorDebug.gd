class_name MP_EditorDebug extends Node

@export var debugging : bool
@export var editor_preview : Node3D
@export var global_viewblocker : Control
@export var console : RichTextLabel
@export var line_deletion_delay : float = 6

var failsafe_skip = false

func _ready():
	if (!debugging): 
		editor_preview.visible = false

func SetViewblockerVis(visible : bool): 
	global_viewblocker.visible = visible

var is_first = true
func SendConsoleMessage(message : String):
	if !is_first: console.append_text("\n")
	is_first = false
	console.add_text(message)
	await get_tree().create_timer(line_deletion_delay, false).timeout
	console.remove_paragraph(0)
	is_first = console.text == ""
