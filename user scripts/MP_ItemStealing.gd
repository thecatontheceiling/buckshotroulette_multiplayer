class_name MP_ItemStealing extends Node

@export var properties : MP_UserInstanceProperties

func BeginItemStealing():
	properties.intermediary.filter.PanLowPass_Out()
	properties.cam.BeginLerp("steal item view")
	await get_tree().create_timer(.4, false).timeout
	properties.permissions.SetMainPermission_Stealing()

func AdrenalineBrightness():
	properties.intermediary.anim_pp_revive.play("adrenaline brightness")

func StealItem(interaction_branch : MP_InteractionBranch):
	var selected_socket_number = interaction_branch.socket_number
	var selected_local_grid_index = interaction_branch.local_grid_index
	var secondary_item_interaction_request_dictionary = {
		"item_id": 8,
		"item_selected_socket_number": selected_socket_number,
		"item_selected_local_grid_index": selected_local_grid_index
	}
	properties.item_interaction.InteractWIthItemRequest_Secondary(secondary_item_interaction_request_dictionary)
