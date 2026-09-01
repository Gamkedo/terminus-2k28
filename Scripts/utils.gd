# Contains various static utility functions to be called from elsewhere
class_name Utils
extends Node

## Hide/show billboard graphics based on direction
static func apply_billboard_graphics(graphic_toward: VisualInstance3D,
	graphic_away: VisualInstance3D, direction: Vector3) -> void:
		# toggle which graphic to show, moving towards or away from camera
		graphic_toward.visible = direction.z>0
		graphic_away.visible = !graphic_toward.visible

## Hide/show billboard graphics, and also turn left/right based on direction
static func apply_billboard_flip_graphics(graphic_toward: VisualInstance3D,
	graphic_away: VisualInstance3D, direction: Vector3) -> void:
		# Start with front/back billboarding
		apply_billboard_graphics(graphic_toward, graphic_away, direction)
		
		# make sprite look left/right based on movement direction
		var cam_rot = graphic_toward.get_viewport().get_camera_3d().rotation.y
		# adjusted_x_rot to account for camera being rotated
		var adjusted_x_rot = direction.x * cos(cam_rot) - direction.z * sin(cam_rot)
		var flip = (adjusted_x_rot < 0)
		graphic_toward.flip_h = flip
		graphic_away.flip_h = flip
