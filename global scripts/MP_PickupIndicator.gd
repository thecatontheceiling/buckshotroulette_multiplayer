class_name MP_PickupIndicator extends Node

@export var interactionBranch : MP_InteractionBranch
@export var obj : Node3D
@export var collider : Node3D

@export var lerping_on_hover : bool
@export var snapping_to_max : bool
@export var snapping_to_min : bool
@export var dur : float
@export var axisOffset : float
@export var originalAxis : float
@export var activeAxis : String
@export var playing_sound : bool = true

@export var itemName : String
@export_multiline var itemDescription : String
var speaker_indicatorCheck : AudioStreamPlayer2D

var lerpEnabled = true
var interactionInvalid = false
var current = 0
var next = 0
var elapsed = 0
var moving = false
var fs = false
var fs2 = true

var intermediary : MP_InteractionIntermed

func _ready():
	speaker_indicatorCheck = get_node("/root/mp_main/speaker parent/speakers_interaction/speaker_indicator check")
	intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")

func _process(delta):
	CheckIfActive()
	if (lerpEnabled && lerping_on_hover): LerpMovement()

func CheckIfActive():
	if ((interactionBranch.interactionAllowed && !interactionInvalid) or !intermediary.intermed_properties.major_permission_enabled):
		if (intermediary.intermed_activeParent != null and intermediary.intermed_activeParent == collider):
			if (!fs):
				BeginPickup()
				fs2 = false
				fs = true
		if (intermediary.intermed_activeParent != collider):
			if (!fs2):
				Revert()
				fs = false
				fs2 = true

func BeginPickup():
	speaker_indicatorCheck.pitch_scale = randf_range(.9, 1.0)
	if playing_sound: speaker_indicatorCheck.play()
	current = originalAxis
	next = axisOffset
	#description.uiArray[0].text = itemName
	#description.uiArray[1].text = itemDescription
	intermediary.intermed_description.uiArray[0].text = itemName
	intermediary.intermed_description.uiArray[1].text = itemDescription
	elapsed = 0
	moving = true
	#description.BeginLerp()
	if (intermediary.intermed_description != null): intermediary.intermed_description.BeginLerp()

func Revert():
	match(activeAxis):
		"x":
			current = obj.transform.origin.x
		"y":
			current = obj.transform.origin.y
		"z":
			current = obj.transform.origin.z
	next = originalAxis
	elapsed = 0
	moving = true

func LerpMovement():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0,  1.0)
		var pos = lerp(current, next, c)
		match(activeAxis):
			"x":
				obj.transform.origin = Vector3(pos, obj.transform.origin.y, obj.transform.origin.z)
			"y":
				obj.transform.origin = Vector3(obj.transform.origin.x, pos, obj.transform.origin.z)
			"z":
				obj.transform.origin = Vector3(obj.transform.origin.x, obj.transform.origin.y, pos)

func SnapToMax():
	match(activeAxis):
		"x":
			obj.transform.origin = Vector3(axisOffset, obj.transform.origin.y, obj.transform.origin.z)
		"y":
			obj.transform.origin = Vector3(obj.transform.origin.x, axisOffset, obj.transform.origin.z)
		"z":
			obj.transform.origin = Vector3(obj.transform.origin.x, obj.transform.origin.y, axisOffset)

func SnapToMin():
	match(activeAxis):
		"x":
			obj.transform.origin = Vector3(originalAxis, obj.transform.origin.y, obj.transform.origin.z)
		"y":
			obj.transform.origin = Vector3(obj.transform.origin.x, originalAxis, obj.transform.origin.z)
		"z":
			obj.transform.origin = Vector3(obj.transform.origin.x, obj.transform.origin.y, originalAxis)











