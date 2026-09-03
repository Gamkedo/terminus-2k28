extends Node

signal round_started(round_number)
signal round_complete(round_number)

var round_number : int = 0

@export var waves : Array[Wave]


func _ready() -> void:
	round_started.emit()
	_start_new_round()


func _start_new_round() -> void:
	round_number += 1
	GameLogger.debug("Starting round %s" % round_number)
	_spawn_enemies()


func _spawn_enemies() -> void:
	var round_wave = waves[round_number - 1]
	for batch in round_wave.enemies:
		await get_tree().create_timer(round_wave.spawn_interval).timeout
		var enemy = batch.enemy_type
		var spawn_amount = batch.spawn_amount
		_spawn_enemy(enemy, spawn_amount)


func _spawn_enemy(enemy, spawn_amount) -> void:
	GameLogger.debug("Spawning %s %s" % [spawn_amount, enemy])


func _end_round() -> void:
	GameLogger.debug("Round %s complete" % round_number)
	round_complete.emit()
	await get_tree().create_timer(2.0).timeout
	_start_new_round()
	
	
