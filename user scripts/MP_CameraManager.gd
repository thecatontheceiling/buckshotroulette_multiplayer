class_name MP_CameraManager extends Node

@export var properties : MP_UserInstanceProperties
@export var cam : Camera3D
@export var obj : Node3D

@export var defib : Node3D
@export var speaker_pan : AudioStreamPlayer2D
@export var socketArray: Array[MP_CameraSocket]

@export var dur : float
var dur_active : float
var dur_original : float
@export var isPlayingSound : bool
var moving = false
var elapsed = 0
var currentPos : Vector3
var currentRot : Vector3
var currentFov : float
var activeIndex
var activeSocket : String
var pos_previous : Vector3
var rot_previous : Vector3

var pos_current_defib : Vector3
var pos_next_defib : Vector3

var lerp_previous = ""

func _ready():
	dur_original = dur

func _process(delta):
	LerpMovement()

var fs = false
func BeginLerp(lerpName : String, moving_slower : bool = false):
	if properties.is_active:
		if lerpName == lerp_previous: return
		lerp_previous = lerpName
		if fs: PanSound()
		activeSocket = lerpName
		for i in range(socketArray.size()):
			if (lerpName == socketArray[i].socketName):
				if moving_slower: dur_active = dur_original * 1.5
				else: dur_active = dur
				activeIndex = i
				pos_current_defib = defib.transform.origin
				pos_next_defib = GetDefibPosition(socketArray[i].fov)
				currentPos = obj.transform.origin
				currentRot = obj.rotation_degrees
				currentFov = cam.fov
				elapsed = 0
				moving = true
		fs = true

func PanSound():
	var pitch = randf_range(.5, 1)
	speaker_pan.pitch_scale = pitch
	if (isPlayingSound): speaker_pan.play()

func SavePrevious():
	rot_previous = cam.rotation_degrees
	pos_previous = cam.transform.origin

func LerpMovement():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur_active, 0.0, 1.0)
		c = ease(c, 0.2)
		var pos = lerp(currentPos, socketArray[activeIndex].pos, c)
		var rot = lerp(currentRot, socketArray[activeIndex].rot, c)
		var fov = lerp(currentFov, socketArray[activeIndex].fov, c)
		var pos_defib = lerp(pos_current_defib, pos_next_defib, c)
		cam.fov = fov
		obj.transform.origin = pos
		obj.rotation_degrees = rot
		defib.transform.origin = pos_defib
		pass

func GetDefibPosition(fov : float):
	var pos : Vector3
	match fov:
		40.5: pos = Vector3(0.21, -2.25, -2.348)
		42.0: pos = Vector3(0.213, -2.315, -2.206)
		42.5: pos = Vector3(0.213, -2.315, -2.206)
		48.0: pos = Vector3(0.224, -2.33, -1.76)
		51.5: pos = Vector3(0.224, -2.33, -1.76)
		58.5: pos = Vector3(0.232, -2.396, -1.448)
		60.0: pos = Vector3(0.232, -2.396, -1.448)
		69.0: pos = Vector3(0.239, -2.385, -1.18)
		69.5: pos = Vector3(0.239, -2.385, -1.18)
	return pos















