class_name WeaponPickupEffect
extends PickupEffect

@export var weapon_number := 0

# TODO, maybe?
#@export var expires_seconds := 0

func apply(player: Player) -> bool:
	if player and player.weapons_manager:
		return player.weapons_manager.add_weapon(weapon_number)
	return false
