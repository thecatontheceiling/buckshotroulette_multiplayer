class_name MP_InteractionManager extends Node

@export var description : MP_DescriptionManager
@export var properties : MP_UserInstanceProperties
@export var cursor : MP_CursorManager
@export var mouseRay : MP_MouseRaycast
@export var item_interaction : MP_ItemInteraction

@export var shotgun : MP_ShotgunInteraction

var activeParent
var activeInteractionBranch
var checking = true
var current_hover_parent = null

var intermediary : MP_InteractionIntermed

func _ready():
	intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")

func _process(delta):
	if (properties.is_active):
		if !properties.camera_look.looking_active && properties.major_permission_enabled:
			CheckPickupLerp()
			CheckInteractionBranch()
			if (checking): CheckIfHovering()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed && !properties.camera_look.looking_active && properties.major_permission_enabled:
		MainInteractionEvent()

func MainInteractionEvent():
	if properties.major_permission_enabled:
		if (activeInteractionBranch != null && activeInteractionBranch.interactionAllowed && !activeInteractionBranch.interactionInvalid):
			var childArray = activeInteractionBranch.get_parent().get_children()
			for i in range(childArray.size()): 
				if (childArray[i] is MP_PickupIndicator): 
					if (childArray[i].snapping_to_max): childArray[i].SnapToMax()
					if (childArray[i].snapping_to_min): childArray[i].SnapToMin()
			InteractWith(activeInteractionBranch.interactionAlias, activeInteractionBranch)

func InteractWith(alias : String, branch : MP_InteractionBranch = null):
	if properties.major_permission_enabled:
		if alias != "inspect mesh": description.EndLerp()
		match alias:
			"shotgun": 
				shotgun.PickupShotgun()
			"hover pan object":
				shotgun.Shoot(activeInteractionBranch)
			"item grid":
				var grid_index = branch.grid_index
				properties.item_manager.PlaceItemRequest(grid_index)
			"item briefcase intake":
				properties.item_manager.GrabItemRequest()
			"item":
				item_interaction.InteractWithItemRequest(branch.get_parent(), properties.is_stealing_item)
			"jammer button":
				var jammer_button : MP_JammerButton = branch.get_parent().get_child(0)
				jammer_button.Press()

func CheckIfHovering():
	if properties.major_permission_enabled:
		if (activeInteractionBranch != null && activeInteractionBranch.interactionAllowed):
			if (activeInteractionBranch.interactionAllowed && !activeInteractionBranch.interactionInvalid && !activeInteractionBranch.interactionInspecting):
				cursor.SetCursorImage("hover")
			else: if (activeInteractionBranch.interactionAllowed && activeInteractionBranch.interactionInvalid):
				cursor.SetCursorImage("invalid")
			else: if (activeInteractionBranch.interactionAllowed && activeInteractionBranch.interactionInspecting):
				cursor.SetCursorImage("eye")
		else:
			cursor.SetCursorImage("point")
	else:
		cursor.SetCursorImage("point")

func CheckPickupLerp():
	if properties.major_permission_enabled:
		if (mouseRay.result != null && mouseRay.result.has("collider") && cursor.cursor_visible):
			if !is_instance_valid(mouseRay.result.collider): return
			var parent = mouseRay.result.collider.get_parent()
			intermediary.intermed_activeParent = parent
			var childArray = parent.get_children()
			for i in range(childArray.size()):
				if (childArray[i] is MP_PickupIndicator):
					var indicator = childArray[i]
			pass
		else:	
			intermediary.intermed_activeParent = null
	else:
		intermediary.intermed_activeParent = null

func CheckInteractionBranch():
	var isFound = null
	if !properties.major_permission_enabled: return
	if (intermediary.intermed_activeParent != null):
		var childArray = intermediary.intermed_activeParent.get_children()
		for i in range(childArray.size()):
			if (childArray[i] is MP_InteractionBranch):
				var branch = childArray[i]
				# activeInteractionBranch = childArray[i]
				isFound = childArray[i]
				break
	if (isFound):
		activeInteractionBranch = isFound
	else:
		activeInteractionBranch = null
