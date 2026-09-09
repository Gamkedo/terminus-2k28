extends Node

signal enemy_spawned

@export var player : Node3D

var enemy_scene_paths: Dictionary = {
	"ROBODOG": "res://Scenes - Objects/enemy_robodog.tscn",
	"DOGELISK": "res://Scenes - Objects/enemy_dogelisk.tscn",
	"ANDROID": "res://Scenes - Objects/enemy_android.tscn",
	"TURRET": "res://Scenes - Objects/enemy_stationary_turret.tscn",
	"ROOMBYE": "res://Scenes - Objects/enemy_roombye.tscn",
	"FLOATING_HEAD": "res://Scenes - Objects/enemy_model_demo.tscn",
	}

func spawn(enemy, spawn_amount) -> void:
	GameLogger.debug("Spawning %s %s" % [spawn_amount, enemy])
	for amount in spawn_amount:
		var resource = load(enemy_scene_paths[enemy])
		var instance = resource.instantiate()
		instance.position = _get_random_spawn_vector()
		add_child(instance)
		enemy_spawned.emit()


func _get_random_spawn_vector() -> Vector3:
	var random_angle = randf_range(0, 2 * PI)
	var direction = Vector3(cos(random_angle), 0.0, sin(random_angle))
	var distance = randf_range(10, 25)
	var spawn_vector = player.global_position + (direction * distance)
	return spawn_vector
