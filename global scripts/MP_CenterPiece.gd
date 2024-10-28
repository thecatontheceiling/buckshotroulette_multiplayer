class_name MP_CenterPiece extends Node

@export var parent : Node3D
@export var socket_rotations : Array[Vector3] #matches socket nr
@export var dur : float
@export var dur_arm_rotation : float
var rot_fore_closed : Vector3
var rot_rear_closed : Vector3
@export var lerp_arm_fore : MP_SeparateLerp
@export var lerp_arm_rear : MP_SeparateLerp
@export var rot_fore_open : Vector3
@export var rot_rear_open : Vector3
var dur_current
var arms_open = false

@export var animators_arm : Array[AnimationPlayer]

@export var speakerctrl_main_rotation : MP_SpeakerController
@export var speaker_latch_close : AudioStreamPlayer2D
@export var speaker_latch_open : AudioStreamPlayer2D
@export var speaker_rotation_hit : AudioStreamPlayer2D
@export var speaker_latch_lock : AudioStreamPlayer2D
@export var speaker_latch_unlock : AudioStreamPlayer2D

var arms_locked_array = ["false", "false"]

var rot_current : Vector3
var rot_next : Vector3
var direction = "CW"

var socket_current = 0
var socket_next = 0
var moving = false
var elapsed = 0
var docked = false

func _ready():
	AssignArmClosedRotations()
	MoveToLoadingDock()

func _process(delta):
	LerpMovement()
	CheckMovement()

func AssignArmClosedRotations():
	rot_fore_closed = lerp_arm_fore.obj.rotation_degrees
	rot_rear_closed = lerp_arm_rear.obj.rotation_degrees

func MoveToSocket(socket_next : float, direction : String = ""):
	moving = false
	fs = false
	var waiting_for_unlock = false
	for i in range(arms_locked_array.size()):
		if arms_locked_array[i]:
			Arms("unlock", i)
			waiting_for_unlock = true
	if (waiting_for_unlock): get_tree().create_timer(.15, false).timeout
	if arms_open: RotateArms_Close()
	
	dur_current = dur
	
	var is_neighbour = true
	if socket_current == 2 && socket_next == 0 or socket_current == 3 && socket_next == 1: is_neighbour = false
	if socket_current == 0 && socket_next == 2 or socket_current == 1 && socket_next == 3: is_neighbour = false
	if parent.rotation_degrees == Vector3(0, 48, 0) && socket_next == 1: is_neighbour = false
	if parent.rotation_degrees == Vector3(0, -132, 0) && socket_next == 0: is_neighbour = false
	if parent.rotation_degrees == Vector3(0, -132, 0) && socket_next == 3: is_neighbour = false
	if !is_neighbour: dur_current *= 2
	
	var overriding = false
	var overriding_parent = false
	if (socket_current == 3 && socket_next == 0): rot_next = Vector3(0, -360, 0); overriding = true
	if (socket_current == 0 && socket_next == 3): rot_next = Vector3(0, 90, 0); overriding = true
	if (docked && socket_current == 0 && socket_next == 2): parent.rotation_degrees = Vector3(0, -311, 0); overriding_parent = true
	rot_current = parent.rotation_degrees
	if !overriding: rot_next = socket_rotations[socket_next]
	
	adding_exponent = false
	elapsed = 0
	socket_current = socket_next
	overriding = false
	moving = true
	LockRotation(true)
	docked = false

func MoveToLoadingDock():
	if docked: return
	moving = false
	fs = false
	if arms_open: RotateArms_Close()
	if (socket_current == 0): rot_next = Vector3(0, 48, 0)
	if (socket_current == 1): rot_next = Vector3(0, -132, 0)
	if (socket_current == 2): rot_next = Vector3(0, -132, 0)
	if (socket_current == 3): rot_next = Vector3(0, -311, 0)
	adding_exponent = true
	rot_current = parent.rotation_degrees
	dur_current = dur
	elapsed = 0
	moving = true
	await(LockRotation())
	Arms("lock")
	docked = true

func LockRotation(opening_arms : bool = false):
	await get_tree().create_timer(dur_current, false).timeout
	adding_exponent = false
	fs = false
	moving = false
	var assigned_rot = rot_next
	if opening_arms: RotateArms_Open()
	if assigned_rot == Vector3(0, -360, 0): parent.rotation_degrees = Vector3(0, 0, 0); return
	if assigned_rot == Vector3(0, 90, 0): parent.rotation_degrees = Vector3(0, -270, 0); return
	parent.rotation_degrees = rot_next

var fs = false
func CheckMovement():
	if moving && !fs:
		PlayMovementSound()
		fs = true

var fs2 = false
func PlayMovementSound():
	if fs2: speakerctrl_main_rotation.speaker.play()
	speakerctrl_main_rotation.fadeDuration = dur_current
	if fs2: speakerctrl_main_rotation.FadeIn()
	await get_tree().create_timer(dur_current, false).timeout
	if fs2: speakerctrl_main_rotation.StopPlaying()
	speaker_rotation_hit.pitch_scale = randf_range(.85, 1)
	if fs2: speaker_rotation_hit.play()
	fs2 = true

func RotateArms_Open():
	await get_tree().create_timer(.2, false).timeout
	speaker_latch_open.play()
	lerp_arm_fore.StartLerp(lerp_arm_fore.obj.transform.origin, lerp_arm_fore.obj.transform.origin, lerp_arm_fore.obj.rotation_degrees, rot_fore_open, 1, dur_arm_rotation)
	lerp_arm_rear.StartLerp(lerp_arm_rear.obj.transform.origin, lerp_arm_rear.obj.transform.origin, lerp_arm_rear.obj.rotation_degrees, rot_rear_open, 1, dur_arm_rotation)
	arms_open = true

func RotateArms_Close():
	speaker_latch_close.play()
	lerp_arm_fore.StartLerp(lerp_arm_fore.obj.transform.origin, lerp_arm_fore.obj.transform.origin, lerp_arm_fore.obj.rotation_degrees, rot_fore_closed, 1, dur_arm_rotation)
	lerp_arm_rear.StartLerp(lerp_arm_rear.obj.transform.origin, lerp_arm_rear.obj.transform.origin, lerp_arm_rear.obj.rotation_degrees, rot_fore_closed, 1, dur_arm_rotation)
	arms_open = false

var fs1 = false
func Arms(anim_name : String, index : int = 2):
	if index == 2:
		for i in animators_arm: 
			i.play(anim_name)
		if (anim_name == "lock"): 
			if fs1: speaker_latch_lock.play()
			for i in range(arms_locked_array.size()): 
				arms_locked_array[i] = true
		else: 
			for i in range(arms_locked_array.size()): 
				arms_locked_array[i] = false
				if fs1: speaker_latch_unlock.play()
	else:
		animators_arm[index].play(anim_name)
		if (anim_name == "lock"): 
			if fs1: speaker_latch_lock.play()
			arms_locked_array[index] = true
		else: 
			arms_locked_array[index] = false
			if fs1: speaker_latch_unlock.play()
	fs1 = true

var adding_exponent = false
func LerpMovement():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur_current, 0, 1)
		if !adding_exponent: c = ease(c, 2)
		else: c = ease(c, 4.8)
		var rot = lerp(rot_current, rot_next, c)
		parent.rotation_degrees = rot


