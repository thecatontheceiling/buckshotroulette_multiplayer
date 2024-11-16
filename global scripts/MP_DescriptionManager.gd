class_name MP_DescriptionManager extends Node

@export var interaction : MP_InteractionManager
@export var uiArray : Array[Label]
@export var dur : float

var intermediary : MP_InteractionIntermed

var elapsed
var moving = false
var current_opacity = 0.0
var next_opacity = 1.0

var started = false
var desc_visible = false

func _ready():
	intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")
	HideText()

func _process(delta):
	LerpText()
	CheckInteraction()

func HideText():
	for i in range(uiArray.size()):
		uiArray[i].modulate.a = 0
	desc_visible = false

func CheckInteraction():
	if (intermediary.intermed_activeParent != null):
		var childArray = intermediary.intermed_activeParent.get_children()
		var found = false
		for i in range(childArray.size()):
			if (childArray[i] is MP_PickupIndicator):
				found = true
				return
		if (!found && started):
			EndLerp()
			started = false

func BeginLerp():
	desc_visible = true
	started = true
	current_opacity = uiArray[0].modulate.a
	next_opacity = 1.0
	elapsed = 0.0
	moving = true
	
func EndLerp():
	desc_visible = false
	current_opacity = uiArray[0].modulate.a
	next_opacity = 0.0
	elapsed = 0.0
	moving = true
	
func LerpText():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0, 1.0)
		var opacity = lerp(current_opacity, next_opacity, c)
		for i in range(uiArray.size()):
			var color = Color(uiArray[i].modulate.r, uiArray[i].modulate.g, uiArray[i].modulate.b, opacity)
			uiArray[i].modulate = color
