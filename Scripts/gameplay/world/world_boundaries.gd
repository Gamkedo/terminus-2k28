extends StaticBody3D

@onready var ground_mesh: GeometryInstance3D = $MeshInstance3D
var bounding_walls: Dictionary[String, CollisionShape3D] = {
	"+x": CollisionShape3D.new(),
	"+z": CollisionShape3D.new(),
	"-x": CollisionShape3D.new(),
	"-z": CollisionShape3D.new(),
}

func _init():
	GameGlobal.world_boundaries = self

func _ready():
	recalculate_boundaries()


## Returns a dict of the distances from origin of each bounding wall.
func get_world_limits() -> Dictionary[String, float]:
	return {
		"+x": bounding_walls["+x"].global_position.x,
		"-x": bounding_walls["-x"].global_position.x,
		"+z": bounding_walls["+z"].global_position.z,
		"-z": bounding_walls["-z"].global_position.z,
	}


## Gives you the normal of a given border wall ("+x", "-x", "+y", "-y".)
func get_border_normal(border: String) -> Vector3:
	assert(border in bounding_walls.keys(), "Border doesn't exist.")

	var plane: Plane
	if border == "+x":
		plane = Plane.PLANE_XY
		return plane.normal.rotated(Vector3.UP, PI)
	elif border == "-x":
		plane = Plane.PLANE_XY
		return plane.normal.rotated(Vector3.UP, 0 * PI)
	elif border == "+z":
		plane = Plane.PLANE_XY
		return plane.normal.rotated(Vector3.UP, PI)
	elif border == "-z":
		plane = Plane.PLANE_XY
		return plane.normal.rotated(Vector3.UP, 0 * PI)
	else:
		# This should never trigger, but Godot was complaining
		# that not all code paths return a value.
		return Vector3.ZERO


## Recalculates the boundaries of the map naively using the ground bounding box (I attempted figuring it out from the geometry but the move sapped my brains.)
func recalculate_boundaries() -> void:
	var ground_bb: AABB = ground_mesh.get_aabb()
	
	for wall_key in bounding_walls.keys():
		var wall: CollisionShape3D = bounding_walls[wall_key]
		wall.shape = WorldBoundaryShape3D.new()
		
		match wall_key:
			"+x":
				wall.name = "+x"
				wall.global_position = ground_mesh.global_position + Vector3(
					0.5 * ground_bb.size.x,
					0,
					0
				)
				wall.shape.plane = Plane.PLANE_YZ
				wall.rotate(Vector3.UP, PI)
			"-x":
				wall.name = "-x"
				wall.global_position = ground_mesh.global_position - Vector3(
					0.5 * ground_bb.size.x,
					0,
					0
				)
				wall.shape.plane = Plane.PLANE_YZ
				wall.rotate(Vector3.UP, 0 * PI)
			"+z":
				wall.name = "+z"
				wall.global_position = ground_mesh.global_position + Vector3(
					0,
					0,
					0.5 * ground_bb.size.x,
				)
				wall.shape.plane = Plane.PLANE_XY
				wall.rotate(Vector3.UP, PI)
			"-z":
				wall.name = "-z"
				wall.global_position = ground_mesh.global_position - Vector3(
					0,
					0,
					0.5 * ground_bb.size.x,
				)
				wall.shape.plane = Plane.PLANE_XY
				wall.rotate(Vector3.UP, 0 * PI)
		
		add_child(bounding_walls[wall_key])
	
