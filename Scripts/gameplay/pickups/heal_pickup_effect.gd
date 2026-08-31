class_name HealPickupEffect
extends PickupEffect

@export var amount: float = 10.0

func apply(player: Player) -> bool:
	if player.health_current >= player.health_max:
		return false # health is full -> do not pick up now
	player.gain_health(amount)
	return true
