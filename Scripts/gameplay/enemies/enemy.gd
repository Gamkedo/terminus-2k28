class_name Enemy
extends Node3D

@export var drop: PackedScene
@export_range(0.0, 1.0) var drop_chance: float = 0.5
@export var scoreValue: int = 100
@export var enemy_type : GameGlobal.EnemyTypes
@export var stun_time: float = 0.0

@onready var health_component := $HealthComponent
## Default to this much health if no health component found
const default_health: float = 50.0

var dead := false
var count_kill_for_wave : bool = true

func _ready() -> void:
	if not is_in_group("enemy"):
		push_error(name + " isn't in enemy group! It won't take damage :(")
	
	if health_component == null:
		push_error(name + " is missing health component! Please add one")
		health_component = HealthComponent.new()
		health_component.set_max_health(default_health)

func die() -> void:
	if dead == true:
		return
	dead = true
	death_explosion()
	GameLogger.debug("%s killed!" % GameGlobal.EnemyTypes.keys()[enemy_type])
	GameGlobal.add_score.emit(scoreValue)
	if count_kill_for_wave == true:
		GameGlobal.enemy_killed.emit(enemy_type)
	_maybe_drop_pickup()
	queue_free()
	
func death_explosion() -> void:
	pass # to override for versions that need script in these cases
	
func enforce_boundary() -> void:
	var limits: Dictionary[String, float] = GameGlobal.world_boundaries.get_world_limits()
	
	if global_position.x > limits["+x"]:
		global_position.x = limits["+x"]
	if global_position.x < limits["-x"]:
		global_position.x = limits["-x"]
	if global_position.z > limits["+z"]:
		global_position.z = limits["+z"]
	if global_position.z < limits["-z"]:
		global_position.z = limits["-z"]

	
func _maybe_drop_pickup() -> void:
	if drop and randf() < drop_chance:
		var pickup := drop.instantiate()
		get_tree().current_scene.add_child(pickup)
		pickup.global_position = global_position
		pickup.global_position.y += 1.0
