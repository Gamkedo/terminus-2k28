class_name Enemy
extends Node3D

@export var drop: PackedScene
@export_range(0.0, 1.0) var drop_chance: float = 0.5
@export var scoreValue: int = 100
@export var enemy_type : GameGlobal.EnemyTypes

@onready var health_component := $HealthComponent

var count_kill_for_wave : bool = true

func die() -> void:
	GameLogger.debug("%s killed!" % GameGlobal.EnemyTypes.keys()[enemy_type])
	
	GameGlobal.add_score.emit(scoreValue)
	if count_kill_for_wave == true:
		GameGlobal.enemy_killed.emit(enemy_type)
	_maybe_drop_pickup()
	queue_free()
	
func _maybe_drop_pickup() -> void:
	if drop and randf() < drop_chance:
		var pickup := drop.instantiate()
		get_tree().current_scene.add_child(pickup)
		pickup.global_position = global_position
		pickup.global_position.y += 1.0
