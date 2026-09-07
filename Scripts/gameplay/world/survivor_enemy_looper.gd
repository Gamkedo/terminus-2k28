## Loop enemies to other edge of screen if they get too far from player
##  Intended for survivor mode
## Also handles spawning enemies now
extends Node

## How frequently to try to loop enemies. It doesn't need to be THAT responsive,
##  so making it longer (to increase performance) is probably fine.
@export var check_frequency: float = 1.5
## Node containing all the enemies. Currently in survivor scene it is "Starter Enemies"
@export var enemy_container: Node3D = null
## How far away from player before looping to other side
@export var loop_range: float = 70.0
## Min range to spawn/loop enemies
@export var spawn_range_min: float = 70.0
## Max range for spawning/looping enemies
@export var spawn_range_max: float = 90.0
## How many enemies we try to keep active at once
@export var target_enemy_count: int = 150
## List of enemy scenes to spawn enemies from
@export var enemy_list: Array[PackedScene]
## Limit maximum number of enemies spawned per frame to maybe help performance
@export var max_spawn_per_frame: int = 30

var check_timer: float = 0.0

func _ready() -> void:
	if !enemy_container:
		push_warning(name + " has no enemy_container set, enemies won't be looped!")

func _process(delta: float) -> void:
	check_timer += delta
	if check_timer >= check_frequency:
		check_timer = 0.0
		
		# Can't do anything if no enemy node to check
		if !enemy_container: return
		
		# Check if enemies need looping
		var player_pos: Vector3 = GameGlobal.player_ref.global_position
		var cur_enemy_count = enemy_container.get_child_count()
		for i in range(cur_enemy_count):
			var cur_enemy: Node3D = enemy_container.get_child(i)
			var orig_y = cur_enemy.global_position.y
			var cur_diff: Vector3 = cur_enemy.global_position - player_pos
			cur_diff.y = 0.0
			if cur_diff.length_squared() > pow(loop_range, 2):
				cur_enemy.global_position = player_pos - cur_diff.normalized() * randf_range(spawn_range_min, spawn_range_max)
				cur_enemy.global_position.y = orig_y
		
		# Spawn more enemies if necessary
		var n_to_spawn = min(target_enemy_count - cur_enemy_count, max_spawn_per_frame)
		for i in range(n_to_spawn):
			# Spawn enemy and add to enemy container node
			var spawned_enemy: Node3D = enemy_list.pick_random().instantiate()
			enemy_container.add_child(spawned_enemy)
			
			# position enemy randomly on edge of circle around player
			var spawn_ang = randf_range(0.0, 2.0 * PI)
			var spawn_dir = Vector3(cos(spawn_ang), 0.0, sin(spawn_ang))
			spawned_enemy.global_position = player_pos + spawn_dir * randf_range(spawn_range_min, spawn_range_max)
