class_name MP_ItemResource extends Resource

@export var instance : PackedScene #item packed scene
@export var id : int #item id
@export var name : String #item name
@export var distribution_enabled : bool #whether or not this item gets distributed to players
@export var max_amount_on_table : int #max item amount per player
@export var max_amount_on_table_global : int #max item amount on the entire table
@export_group("audio")
@export var sound_pick_up_fp : AudioStream #sound when the item is picked up on the table (first person)
@export var sound_place_down_fp : AudioStream #sound when the item is placed down on the table (first person)
@export var sound_pick_up_tp : AudioStream #sound when the item is picked up on the table (third person)
@export var sound_place_down_tp : AudioStream #sound when the item is placed down on the table (third person)
@export var sound_initial_interaction_fp : AudioStream #interaction sound that gets played after item pickup (first person)
@export var sound_initial_interaction_tp : AudioStream #interaction sound that gets played after item pickup (third person)
@export_group("offsets")
@export var pos_in_briefcase_local : Vector3 #item position in briefcase that the lerp starts from
@export var rot_in_briefcase_local : Vector3 #item rotation in briefcase that the lerp starts from
@export var pos_out_briefcase_local : Vector3 #item position outside of briefcase that the lerp ends at
@export var rot_out_briefcase_local : Vector3 #item rotation outside of briefcase that the lerp ends at
@export var pos_Y_offset_from_carriage : float #y offset from the item remover machine part that grabs items
@export var pos_grid_offset_array_local : Array[Vector3] #item position offset on the grid when placed [0, 1, 2, 3, 4, 5, 6, 7]
@export var rot_grid_offset_array_local : Array[Vector3] #item rotation offset on the grid when placed [0, 1, 2, 3, 4, 5, 6, 7]

#check 'item properties' group under MP_UserInstanceProperties
