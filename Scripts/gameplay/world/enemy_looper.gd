## Loop enemies to other edge of screen if they get too far from player
extends Node

## How frequently to try to loop enemies. It doesn't need to be THAT responsive,
##  so making it longer (to increase performance) is probably fine.
@export var check_frequency: float = 1.5
## Node containing all the enemies. Currently in survivor scene it is "Starter Enemies"
@export var enemy_container: Node3D = null
## How far away from player before looping to other side
@export var loop_range: float = 70.0

var check_timer: float = 0.0

func _ready() -> void:
	if !enemy_container:
		push_warning(name + " has no enemy_container set, enemies won't be looped!")

func _process(delta: float) -> void:
	check_timer += delta
	if check_timer >= check_frequency:
		check_timer = 0.0
		
		if !enemy_container: return
		
		var player_pos = GameGlobal.player_ref.global_position
		for i in range(enemy_container.get_child_count()):
			var cur_enemy: Node3D = enemy_container.get_child(i)
			var orig_y = cur_enemy.global_position.y
			var cur_diff: Vector3 = cur_enemy.global_position - player_pos
			cur_diff.y = 0.0
			if cur_diff.length_squared() > pow(loop_range, 2):
				cur_enemy.global_position = player_pos - cur_diff.normalized() * loop_range
				cur_enemy.global_position.y = orig_y
