# Acts like enemy_billboard_demo, but flips sprite left/right based on movement direction
#  (for directional sprites) (intended for use in arcade scene)

extends "res://Scripts/gameplay/enemies/enemy_billboard_demo.gd"

func pick_new_direction():
	super.pick_new_direction() # base behavior
	
	# make sprite look left/right based on movement direction
	var cam_rot = get_viewport().get_camera_3d().rotation.y
	# adjusted_x_rot to account for camera being rotated
	var adjusted_x_rot = direction.x * cos(cam_rot) - direction.z * sin(cam_rot)
	var flip = (adjusted_x_rot < 0)
	graphic_toward.flip_h = flip
	graphic_away.flip_h = flip
