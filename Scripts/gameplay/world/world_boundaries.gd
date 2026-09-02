extends StaticBody3D

@onready var ground_mesh: GeometryInstance3D = $MeshInstance3D
var bounding_walls: Dictionary[String, CollisionShape3D] = {
	"+x": CollisionShape3D.new(),
	"+z": CollisionShape3D.new(),
	"-x": CollisionShape3D.new(),
	"-z": CollisionShape3D.new(),
}

func _ready():
	var ground_bb: AABB = ground_mesh.get_aabb()
	
	for wall_key in bounding_walls.keys():
		var wall: CollisionShape3D = bounding_walls[wall_key]
		wall.shape = WorldBoundaryShape3D.new()
		
		match wall_key:
			"+x":
				wall.global_position = ground_mesh.global_position + Vector3(
					0.5 * ground_bb.size.x,
					0,
					0
				)
				wall.shape.plane = Plane.PLANE_YZ
				wall.rotate(Vector3.UP, PI)
			"-x":
				wall.global_position = ground_mesh.global_position - Vector3(
					0.5 * ground_bb.size.x,
					0,
					0
				)
				wall.shape.plane = Plane.PLANE_YZ
				wall.rotate(Vector3.UP, 0 * PI)
			"+z":
				wall.global_position = ground_mesh.global_position + Vector3(
					0,
					0,
					0.5 * ground_bb.size.x,
				)
				wall.shape.plane = Plane.PLANE_XY
				wall.rotate(Vector3.UP, PI)
			"-z":
				wall.global_position = ground_mesh.global_position - Vector3(
					0,
					0,
					0.5 * ground_bb.size.x,
				)
				wall.shape.plane = Plane.PLANE_XY
				wall.rotate(Vector3.UP, 0 * PI)
		
		add_child(bounding_walls[wall_key])
