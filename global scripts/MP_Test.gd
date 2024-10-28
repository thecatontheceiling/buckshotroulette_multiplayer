class_name MP_Test extends Node3D

func Get(obj1 : Node3D, obj2 : Node3D):
	var dir = (obj1.global_position - obj2.global_position).normalized()
	var rot = atan2(dir.x, dir.z)
	print("test: ", rad_to_deg(rot))
