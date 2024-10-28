class_name MP_UserTimeout extends Node

@export var timeout_lerp_branch_array : Array[MP_UserTimeout_BarLerp]
@export var timeout_branch_array : Array[MP_UserTimeout_Branch]

func ResetAllTimeouts():
	if !GlobalVariables.timeouts_enabled: return
	for timeout in timeout_lerp_branch_array:
		match timeout.assigned_name:
			"divider bar":
				timeout.ResetLerp()
			"vertical counter bar":
				timeout.SetScaleToMinimum()
			"item briefcase bar":
				timeout.SetScaleToMinimum()
			"jammer bar":
				timeout.SetScaleToMinimum()

func StartCountingTimeout(type : String, timeout_length : float):
	if !GlobalVariables.timeouts_enabled: return
	for i in timeout_branch_array:
		if i.branch_alias == type:
			i.StartTimeoutOnBranch(timeout_length)
	for i in timeout_lerp_branch_array:
		if i.assigned_type == type:
			i.StartLerp(timeout_length)

func StopCountingAllTimeouts():
	if !GlobalVariables.timeouts_enabled: return
	for i in timeout_branch_array:
		i.StopTimeoutOnBranch()
	for i in timeout_lerp_branch_array:
		i.EndLerp()
		match i.assigned_name:
			"divider bar":
				i.ResetLerp()
			"vertical counter bar":
				i.SetScaleToMinimum()
			"item briefcase bar":
				i.SetScaleToMinimum()
			"jammer bar":
				i.SetScaleToMinimum()

func StopCountingTimeout(type : String):
	if !GlobalVariables.timeouts_enabled: return
	for i in timeout_branch_array:
		if i.branch_alias == type:
			i.StopTimeoutOnBranch()
	for i in timeout_lerp_branch_array:
		if i.assigned_type == type:
			i.EndLerp()
			match i.assigned_name:
				"divider bar":
					i.ResetLerp()
				"vertical counter bar":
					i.SetScaleToMinimum()
				"item briefcase bar":
					i.SetScaleToMinimum()
				"jammer bar":
					i.SetScaleToMinimum()
