extends MeshInstance3D

var osc := 0.0

func _process(delta: float) -> void:
	osc += delta*5.0
	scale = Vector3.ONE * (1.0+0.25*sin(osc))
	rotate(Vector3.FORWARD, 25.0 * delta)
