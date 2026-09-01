# Acts like enemy_billboard_demo, but flips sprite left/right based on movement direction
#  (for directional sprites) (intended for use in arcade scene)

extends "res://Scripts/gameplay/enemies/enemy_billboard_demo.gd"

func pick_new_direction():
	super.pick_new_direction() # base behavior
	
	Utils.apply_billboard_flip_graphics(graphic_toward, graphic_away, direction)
