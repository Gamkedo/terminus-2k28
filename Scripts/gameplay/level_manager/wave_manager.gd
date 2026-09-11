extends Node

## TODO enemy count && checks for round end triggers

signal round_started(round_number)
signal round_complete(round_number)
signal round_timeout(round_number)

var round_number : int = 0
var round_timer : Timer
var number_of_enemies : int = 0
var spawning_complete = false

@export var enemy_spawner : Node
@export var waves : Array[Wave]


func _ready() -> void:
	GameGlobal.enemy_killed.connect(_on_enemy_killed)
	enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)
	_set_up_timer()
	_start_new_round()


func _set_up_timer() -> void:
	round_timer = Timer.new()
	round_timer.timeout.connect(_on_round_timer_timout)
	round_timer.one_shot = true
	add_child(round_timer)


func _start_new_round() -> void:
	spawning_complete = false
	round_number += 1
	round_timer.wait_time = waves[round_number - 1].round_time_limit
	round_timer.start(30.0)
	round_started.emit()
	GameLogger.debug("Starting round %s" % round_number)
	GameGlobal.wave_changed.emit(round_number)
	_spawn_enemies()


func _spawn_enemies() -> void:
	var round_wave = waves[round_number - 1]
	for batch in round_wave.enemies:
		await get_tree().create_timer(round_wave.spawn_interval).timeout
		var enemy = GameGlobal.EnemyTypes.keys()[batch.enemy_type]
		var spawn_amount = batch.spawn_amount
		enemy_spawner.spawn(enemy, spawn_amount)
	spawning_complete = true


func _on_enemy_spawned() -> void:
	number_of_enemies += 1
	GameLogger.debug("%s enemies left! " % number_of_enemies)


func _on_enemy_killed(enemy_type) -> void:
	number_of_enemies -= 1
	GameLogger.debug("%s enemies left! " % number_of_enemies)
	if number_of_enemies == 0 and spawning_complete:
		_end_round()


func _on_round_timer_timout() -> void:
	GameLogger.debug("Round %s time up!" % round_number)
	round_timeout.emit()
	await get_tree().create_timer(2.0).timeout
	if round_number < waves.size():
		_start_new_round()


func _end_round() -> void:
	GameLogger.debug("Round %s complete" % round_number)
	round_complete.emit()
	await get_tree().create_timer(2.0).timeout
	if round_number < waves.size():
		_start_new_round()
