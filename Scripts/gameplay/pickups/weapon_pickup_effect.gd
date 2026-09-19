class_name WeaponPickupEffect
extends PickupEffect

@export var weapon_number := 0
@export var expires_seconds := 0

func apply(player: Player) -> bool:
	return false
