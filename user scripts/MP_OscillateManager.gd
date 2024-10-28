class_name MP_OscillateManager extends Node

@export var oscillators : Array[MP_Oscillate]

func StartOscillating(alias : String):
	if alias == "all":
		for osc in oscillators: osc.StartOscillating()
		return
	else:
		for osc in oscillators:
			if osc.alias == alias:
				osc.StartOscillating()
				break

func StopOscillating(alias : String):
	if alias == "all":
		for osc in oscillators: osc.StopOscillating()
		return
	else:
		for osc in oscillators:
			if osc.alias == alias:
				osc.StopOscillating()
				break

func LerpToOriginal(alias : String):
	if alias == "all":
		for osc in oscillators: 
			osc.StopOscillating()
			osc.LerpToOriginal()
		return
	else:
		for osc in oscillators:
			if osc.alias == alias:
				osc.StopOscillating()
				osc.LerpToOriginal()
				break
