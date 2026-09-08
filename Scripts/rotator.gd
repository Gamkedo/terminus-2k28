extends Node3D

@export var rot_amount: Vector3 = Vector3(0,1,0)

func _process(delta: float) -> void:
	rotation += rot_amount * delta
