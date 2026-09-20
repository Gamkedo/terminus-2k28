class_name HealPickupEffect
extends PickupEffect

@export var amount: float = 10.0

func apply(player: Player) -> bool:
	AudioStreamManager.play_sfx("res://Sound Effects/Pickups/pickup_sound_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
	player.gain_health(amount)
	return true # always ingesting up powerup, if player didn't need it they should avoid it until ready
