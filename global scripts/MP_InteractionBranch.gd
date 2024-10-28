class_name MP_InteractionBranch extends Node

@export var properties : MP_UserInstanceProperties #user instance properties
@export var interactionAlias : String #interaction alias. example "door handle"
@export var interactionAlias_sub : String #sub alias. example "handle 6", like when opening a cupboard you dont wanna do "handle 1", "handle 2", "handle 3", etc
@export var itemName : String #item name
@export var item_id : int #item ID. 1 to ...
@export var interactionAllowed : bool #if disabled, hovering over the thing doesn't show the clickable cursor
@export var interactionInvalid : bool #if an interaction is invalid, it will show the denied symbol
@export var interactionInspecting : bool #shows an eye symbol on hover
@export var local_grid_index : int #local grid position that the item is placed on. 0, 1, 2, 3, 4, 5, 6, 7
@export var socket_number : int #user socket number that the item is placed on. 0, 1, 2, 3
@export var which_hand_to_grab_with : String #which hand the third person user grabs the item with
@export var has_secondary_interaction : bool #whether or not the item has another interaction after picking it up. like the jammer, for example.
@export var grid_index : int #what is this. is this the same as local grid index?
