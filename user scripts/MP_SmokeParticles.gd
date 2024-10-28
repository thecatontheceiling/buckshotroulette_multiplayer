class_name MP_SmokeParticles extends Node

@export var smoke_instance : PackedScene
@export var smoke_parent : Node3D

@export var blood_instance : PackedScene
@export var blood_parent : Node3D

func SpawnSmoke(at_pos : Vector3):
	var smoke = smoke_instance.instantiate()
	var emitter = smoke.get_child(0)
	smoke_parent.add_child(smoke)
	smoke.transform.origin = at_pos
	emitter.emitting = true

func SpawnBlood(at_rot : Vector3):
	var blood = blood_instance.instantiate()
	var emitter = blood.get_child(0)
	blood_parent.add_child(blood)
	blood.rotation_degrees = at_rot
	blood.transform.origin = Vector3(14.906, 5.029, 0.302)
	emitter.emitting = true
