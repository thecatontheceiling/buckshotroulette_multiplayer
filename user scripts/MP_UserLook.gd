class_name MP_UserLook extends Node

@export var parent : Node3D
@export var dur : float
@export var properties : MP_UserInstanceProperties
@export var mouse : MP_MouseRaycast
@export var rot_left : Vector3
@export var rot_forward : Vector3
@export var rot_right : Vector3
@export var rot_self : Vector3
@export var curve : Curve

var rot_current : Vector3
var rot_next : Vector3
var elapsed = 0
var moving = false
var checking = false

func _process(delta):
	Lerp()
	CheckDirection()

var lastDirection = ""

func CheckDirection():
	if checking && properties.is_active:
		var x = mouse.eventpos.x
		var direction = ""
		if x >= 0 and x <= 350:
			direction = "left"
		elif x > 350 and x <= 611:
			direction = "forward"
		elif x > 611 and x <= 960:
			direction = "right"
		if direction != lastDirection:
			lastDirection = direction
			LookAtDirection(direction)
			var packet = {
			"packet category": "MP_PacketVerification",
			"packet alias": "look at user request",
			"sent_from": "client",
			"packet_id": 15,
			"sent_from_socket": properties.socket_number,
			"direction_to_look": direction,
			}
			properties.intermediary.packets.send_p2p_packet_directly_to_host(GlobalSteam.STEAM_ID, packet)
			if GlobalVariables.mp_debugging: properties.intermediary.packets.PipeData(packet)

func LookAtDirection_Forward():
	LookAtDirection("forward")

func ReceivePacket_Look(packet_dictionary : Dictionary = {}):
	var socket_that_is_looking = packet_dictionary.socket_number
	var direction_to_look = packet_dictionary.direction_to_look
	if socket_that_is_looking == properties.socket_number:
		LookAtDirection(direction_to_look)

func LookAtDirection(direction : String):
	moving = false
	match direction:
		"left": rot_next = rot_left
		"forward": rot_next = rot_forward
		"right": rot_next = rot_right
		"self": rot_next = rot_self
	rot_current = parent.rotation_degrees
	elapsed = 0
	moving = true

func Lerp():
	if moving:
		elapsed += get_process_delta_time()
		var d  = clampf(elapsed / dur, 0.0, 1.0)
		#c = clampf(curve.sample(elapsed), 0.0, 1.0)
		var c = curve.sample(d)
		#c = ease(c, curve.sample(elapsed))
		var rot = lerp(rot_current, rot_next, c)
		parent.rotation_degrees = rot
