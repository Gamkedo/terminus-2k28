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
	await get_tree().create_timer(3.0).timeout
	randomvoice()


func randomvoice():
	var rng = randi_range(0,21)
	match rng:
		0:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_attack_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
		1:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_attack_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
		2:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_deploying_countermeasures_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
		3:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_deploying_countermeasures_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
		4:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_do_not_attempt_to_resist_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
		5:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_do_not_attempt_to_resist_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
		6:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_eliminate_the_agitator_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
		7:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_eliminate_the_agitator_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
		8:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_hostile_presence_detected_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
		9:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_hostile_presence_detected_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
		10:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_incursion_identified_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
		11:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_incursion_identified_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
		12:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_incursion_identified_3.wav", AudioStreamManager.PlaybackMode.STANDARD)
		13:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_remove_the_instigator_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
		14:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_remove_the_instigator_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
		15:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_remove_the_instigator_3.wav", AudioStreamManager.PlaybackMode.STANDARD)
		16:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_seek_and_destroy_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
		17:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_seek_and_destroy_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
		18:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_seek_and_destroy_3.wav", AudioStreamManager.PlaybackMode.STANDARD)
		19:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_threat_in_the_area_1.wav", AudioStreamManager.PlaybackMode.STANDARD)
		20:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_threat_in_the_area_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
		21:
			AudioStreamManager.play_sfx("res://Sound Effects/Voiceover/vo_threat_in_the_area_3.wav", AudioStreamManager.PlaybackMode.STANDARD)


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
		AudioStreamManager.play_sfx("res://Sound Effects/Wave States/new_wave.wav", AudioStreamManager.PlaybackMode.STANDARD)
		_start_new_round()
	else: # ideally we handle end wave more gracefully, but at minimum, can't leave game stuck for now
		if get_tree().current_scene.name.contains("Arc"):
			GameGlobal.won_arc = true
		elif get_tree().current_scene.name.contains("Imm"):
			GameGlobal.won_imm = true
		
		get_tree().change_scene_to_file("res://level_menu.tscn")
