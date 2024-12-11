class_name MP_UserPermissions extends Node

@export var properties : MP_UserInstanceProperties
@export var cursor : MP_CursorManager
var intermediary : MP_InteractionIntermed
var item_interaction_invalid_array_by_id = []

func _ready():
	intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")
	SetMainPermission(false)

func SetMajorPermission(state : bool):
	if !state:
		if intermediary.intermed_activeParent != null:
			for i in range(intermediary.intermed_activeParent.get_children().size()):
				if intermediary.intermed_activeParent.get_children()[i] is MP_PickupIndicator:
					intermediary.intermed_activeParent.get_children()[i].Revert()
					properties.description.EndLerp()
					properties.description.started = false
		properties.major_permission_enabled = state
		cursor.SetCursor(false, false)
	else:
		properties.major_permission_enabled = true
		cursor.SetCursor(GlobalVariables.cursor_state_after_toggle, false)

func SetMainPermission(state : bool):
	SetPermission_Shotgun(state)
	SetItemPermissions(state)
	GlobalVariables.cursor_state_after_toggle = state
	cursor.SetCursor(state, state)
	if !state:
		properties.SetTurnControllerPrompts(false)

func SetMainPermission_Stealing():
	SetPermission_Shotgun(false)
	SetItemPermissions(true, true)
	GlobalVariables.cursor_state_after_toggle = true
	cursor.SetCursor(true, true)
	properties.SetAdrenalineControllerPrompts(true)

func SetPermission_Shotgun(state : bool):
	intermediary.intbranch_shotgun.interactionAllowed = state

func SetItemPermissions(state : bool, for_all_items_on_table : bool = false):
	for socket in range(properties.intermediary.game_state.MAIN_inventory_by_socket.size()):
		if socket != properties.socket_number:
			for dict in properties.intermediary.game_state.MAIN_inventory_by_socket[socket]:
				if dict != {}:
					var pickup_indicator : MP_PickupIndicator = dict.item_instance.get_child(0)
					var interaction_branch : MP_InteractionBranch = dict.item_instance.get_child(1)
					interaction_branch.interactionAllowed = false
					pickup_indicator.lerping_on_hover = false
	
	var invalid_item_id_array = properties.intermediary.game_state.GetPropertyInvalidItems(properties)
	var item_array_to_check_permissions_on = []
	if !for_all_items_on_table:
		#setting permissions for items that are only on the player's side of the table
		item_array_to_check_permissions_on = properties.user_inventory_instance_array
	else:
		#setting permissions for items that are not on the player's side of the table (when stealing an item with adrenaline)
		for socket in range(properties.intermediary.game_state.MAIN_inventory_by_socket.size()):
			if socket != properties.socket_number:
				for dict in properties.intermediary.game_state.MAIN_inventory_by_socket[socket]:
					if dict != {}:
						item_array_to_check_permissions_on.append(dict.item_instance)
	for item in item_array_to_check_permissions_on:
		if item != null:
			var pickup_indicator : MP_PickupIndicator = item.get_child(0)
			var interaction_branch : MP_InteractionBranch = item.get_child(1)
			if state:
				if invalid_item_id_array[interaction_branch.item_id] == true:
					interaction_branch.interactionAllowed = true
					interaction_branch.interactionInvalid = true
					pickup_indicator.interactionInvalid = true
					pickup_indicator.lerping_on_hover = false
				else:
					interaction_branch.interactionAllowed = state
					pickup_indicator.lerping_on_hover = state
					interaction_branch.interactionInvalid = false
					pickup_indicator.interactionInvalid = false
			else:
				interaction_branch.interactionAllowed = state
				pickup_indicator.lerping_on_hover = state
				interaction_branch.interactionInvalid = false
				pickup_indicator.interactionInvalid = false
	if !for_all_items_on_table:
		for property in intermediary.instance_handler.instance_property_array:
			property.inspection.SetInspectObject(false)
			if property.socket_number != properties.socket_number:
				if state:
					if property.health_current != 0:
						property.inspection.SetInspectObject(state)
				else:
					property.inspection.SetInspectObject(state)
