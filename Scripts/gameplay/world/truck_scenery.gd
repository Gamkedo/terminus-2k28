extends DestructScenery


func die() -> void:
	super.die()
	remove_from_group("enemy")
