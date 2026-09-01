class_name Enemy
extends Node3D

@export var drop: PackedScene
@export_range(0.0, 1.0) var drop_chance: float = 0.5
@export var scoreValue: int = 100

func die() -> void:
	GameGlobal.add_score.emit(scoreValue)
	_maybe_drop_pickup()
	queue_free()
	
func _maybe_drop_pickup() -> void:
	if drop and randf() < drop_chance:
		var pickup := drop.instantiate()
		get_tree().current_scene.add_child(pickup)
		pickup.global_position = global_position
		pickup.global_position.y += 1.0
