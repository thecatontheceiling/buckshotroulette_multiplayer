class_name MP_HoverPan extends Node

@export var properties : MP_UserInstanceProperties
@export var death : MP_DeathManager
@export var intbranch : MP_InteractionBranch
@export var mesh_instance : MeshInstance3D
@export var mesh_instance_self : MeshInstance3D
@export var collision_shape : CollisionShape3D
@export var collision_shape_self : CollisionShape3D
@export var ui_self : Control

var intermediary : MP_InteractionIntermed
var is_hovering = false

func _ready():
	if properties.is_active: intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")

func _process(delta):
	if (properties.is_active):
		CheckHover()

func SetInteractionState(): #check if user has returned from revival
	intbranch.interactionAllowed = death.user_returned_from_death

func SetState(): 
	collision_shape.disabled = !(!properties.is_active && properties.health_current != 0)
	collision_shape_self.disabled = !properties.is_active

func Disable():
	collision_shape.disabled = true
	collision_shape_self.disabled = true

func CheckHover():
	if intermediary.intermed_activeParent == mesh_instance_self:
		ui_self.self_modulate.a = .5
	else:
		ui_self.self_modulate.a = 1
	if (intermediary.intermed_activeParent == mesh_instance or intermediary.intermed_activeParent == mesh_instance_self):
		is_hovering = true
	else:
		is_hovering = false
