class_name MP_UserTimeout_Branch extends Node

@export var properties : MP_UserInstanceProperties
@export var branch_alias : String
@export var assigned_lerp_branch_array : Array[MP_UserTimeout_BarLerp]

var current_timeout_length
var current_timeout_count
var counting_timeout = false

func _process(delta):
	CountTimeout()

func StartTimeoutOnBranch(timeout_length : float):
	current_timeout_count = 0
	current_timeout_length = timeout_length + .6
	fs = false
	counting_timeout = true

func StopTimeoutOnBranch():
	counting_timeout = false
	current_timeout_count = 0
	current_timeout_length = 0
	fs = false

var fs = false
func CountTimeout():
	if counting_timeout:
		current_timeout_count += get_process_delta_time()
		if current_timeout_count >= current_timeout_length && !fs:
			TimeoutReached()
			fs = true

func TimeoutReached():
	print("timeout reached on branch alias: ", branch_alias)
	properties.intermediary.game_state.OnTimeoutReached(branch_alias, properties.socket_number)
	for i in assigned_lerp_branch_array:
		i.EndLerp()
