class_name DefaultEnemyMovementHandler extends NavigationMovementHandler


func get_current_movement_speed() -> float:
	return enemy.speed

func get_max_movement_speed() -> float:
	return enemy.speed

func move(in_velocity:Vector3, _physics_delta:float) -> void:
	var projected_velocity := Utils.grid_vector(in_velocity).normalized()
	var direction:Vector3 = Vector3(projected_velocity.x, 0.0, projected_velocity.y)
	
	enemy.direction = direction
