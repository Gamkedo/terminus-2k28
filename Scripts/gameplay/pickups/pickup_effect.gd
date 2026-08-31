class_name PickupEffect
extends Resource

# Override. Make this return true if the pickup item should be consumed
func apply(player: Player) -> bool:
	return true
