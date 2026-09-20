## Projectiles the enemies shoot that hurt the player
extends LaserBolt

func _on_area_entered(_area):
	# print(area.name)
	explode_and_remove()

func _on_body_entered(body):
	# print(body.name)
	if body.is_in_group("player"):
		var player: Player = body as Player
		player.reduce_health(damage_component.amount)
		AudioStreamManager.play_sfx("res://Sound Effects/Player/player_damage_1.wav", AudioStreamManager.PlaybackMode.RANDOM_PITCH)
		explode_and_remove()
