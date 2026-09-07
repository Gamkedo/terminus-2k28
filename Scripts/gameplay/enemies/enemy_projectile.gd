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
		explode_and_remove()
