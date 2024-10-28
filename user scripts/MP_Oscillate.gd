class_name MP_Oscillate extends Node

@export var alias : String
@export var properties : MP_UserInstanceProperties
@export var parent : Node3D
@export var amplitude : float
@export var offset : float
@export var frequency : float
@export var frequency_r1 : float = .5
@export var frequency_r2 : float = 1.5

var oscillating = false
var lerping_to_orig = false
var time = 0
var initial_y
var elapsed = 0.0
var dur = .5
var y_current : float
var y_next : float
var prev_y = 0

func _ready():
	initial_y = parent.transform.origin.y

func _process(delta):
	OscillateAxis()
	LerpOriginalAxis()
	if properties != null:
		if properties.socket_number == properties.intermediary.game_state.MAIN_active_current_turn_socket:
			if alias == "shotgun":
				#print("oscillating: ", oscillating, " lerping to original: ", lerping_to_orig)
				pass

func SetRandomFrequency():
	frequency = randf_range(frequency_r1, frequency_r2)

func StartOscillating():
	time = 0
	new_y = 0
	lerping_to_orig = false
	oscillating = true

func StopOscillating():
	#prev_y = y
	lerping_to_orig = false
	oscillating = false

func LerpToOriginal():
	oscillating = false
	y_current = parent.transform.origin.y
	y_next = initial_y
	elapsed = 0
	lerping_to_orig = true

func LerpOriginalAxis():
	if lerping_to_orig:
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0, 1.0)
		c = ease(c, -3)
		var y_new = lerp(y_current, y_next, c)
		parent.transform.origin = Vector3(parent.transform.origin.x, y_new, parent.transform.origin.z)

var new_y
func OscillateAxis():
	if oscillating:
		time += get_process_delta_time()
		var new_y = (sin(time * frequency) + amplitude) / offset
		# Calculate the cumulative offset caused by the oscillation
		var oscillation_offset = initial_y + new_y - parent.transform.origin.y + .18
		# Apply the cumulative offset
		parent.transform.origin += Vector3(0, oscillation_offset, 0)
