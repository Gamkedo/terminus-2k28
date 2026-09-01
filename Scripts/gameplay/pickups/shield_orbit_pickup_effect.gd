class_name ShieldOrbitPickupEffect
extends PickupEffect

## Scene of shield orbiter to spawn
@export var shield_orbiter_scene: PackedScene = null
## How many orbiters to spawn
@export var orbiter_count = 4

func apply(player: Player) -> bool:
	# spawn orbiters around player. If no scene assigned, return false and fail
	if shield_orbiter_scene:
		var orbit_spacing = (PI * 2.0) / orbiter_count
		for i in orbiter_count:
			var cur_orbiter = shield_orbiter_scene.instantiate()
			player.get_tree().current_scene.add_child(cur_orbiter)
			cur_orbiter.set_orbit_target(player, orbit_spacing * i)
		return true
	else:
		print("No shield_orbiter_scene set for shield orbit pickup!")
		return false
