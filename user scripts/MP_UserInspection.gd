class_name MP_UserInspection extends Node

@export var properties : MP_UserInstanceProperties
@export var collider : CollisionShape3D
@export var pickup_indicator : MP_PickupIndicator
@export var interaction_branch : MP_InteractionBranch

func _ready():
	SetName()
	SetInspectObject(false)

func SetName():
	pickup_indicator.itemName = properties.user_name

func SetInspectObject(enabling : bool):
	collider.disabled = !enabling
