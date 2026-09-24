extends Node

signal enemy_spawned

@export var player : Node3D
@export var spawn_effect : PackedScene

var enemy_scene_paths: Dictionary = {
	"ROBODOG": "res://Scenes - Objects/enemy_robodog.tscn",
	"DOGELISK": "res://Scenes - Objects/enemy_dogelisk.tscn",
	"ANDROID": "res://Scenes - Objects/enemy_android.tscn",
	"TURRET": "res://Scenes - Objects/enemy_stationary_turret.tscn",
	"ROOMBYE": "res://Scenes - Objects/enemy_roombye.tscn",
	"QUADCOPTER": "res://Scenes - Objects/enemy_quadcopter.tscn",
	"FLOATING_HEAD": "res://Scenes - Objects/enemy_model_demo.tscn",
	"SMART_DROID": "res://Scenes - Objects/enemy_model_demo.tscn",
	}

func spawn(enemy, spawn_amount) -> void:
	GameLogger.debug("Spawning %s %s" % [spawn_amount, enemy])
	for amount in spawn_amount:
		var resource = load(enemy_scene_paths[enemy])
		var instance = resource.instantiate()
		var spawnPos = _get_random_spawn_vector()
		instance.position = spawnPos
		add_child(instance)
		enemy_spawned.emit()
		if spawn_effect != null:
			instance.enforce_boundary()
			spawnPos = instance.position
			# reusing, isntance will now be the effect
			instance = spawn_effect.instantiate()
			instance.position = spawnPos
			add_child(instance)


func _get_random_spawn_vector() -> Vector3:
	var random_angle = randf_range(0, 2 * PI)
	var direction = Vector3(cos(random_angle), 0.0, sin(random_angle))
	var distance = randf_range(10, 25)
	var spawn_vector = player.global_position + (direction * distance)
	return spawn_vector
