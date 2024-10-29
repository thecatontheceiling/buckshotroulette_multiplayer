class_name MP_ShellLoader extends Node

@export var game_state : MP_GameStateManager
@export var shell_instance_array : Array[Node3D]

var spawned_instance_array = []

func SpawnShells(): #i believe this does nothing
	var sequence = game_state.MAIN_active_sequence_dict.sequence_visible
	for shell in shell_instance_array:
		shell.visible = false
	for i in range(sequence.size()):
		shell_instance_array[i].visible = true
		var shell_branch : MP_ShellBranch = shell_instance_array[i].get_child(0)
		shell_branch.SetState(sequence[i])
