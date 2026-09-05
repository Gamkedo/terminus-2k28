## Projectiles the enemies shoot that hurt the player
extends LaserBolt

## How long before projectile is automatically destroyed (like if it travels out of bounds for example)
@export var projectile_damage := 10.0

func _on_area_entered(_area):
	# print(area.name)
	explode_and_remove()

func _on_body_entered(body):
	# print(body.name)
	if body.is_in_group("player"):
		var player: Player = body as Player
		player.reduce_health(projectile_damage)
		explode_and_remove()
