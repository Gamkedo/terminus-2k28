class_name AutoAimComponent
extends AimComponent

### How often do we recalculate the closest enemy?
@export var recalc_seconds: float = 0.1

var recalc_in_seconds: float = 0.0
var targeted_enemy: Node3D

func handle_aiming(player: Player, delta: float) -> void:
	recalc_in_seconds -= delta
	if recalc_in_seconds <= 0.0:
		targeted_enemy = _find_closest_enemy(player)
		recalc_in_seconds = recalc_seconds
	if targeted_enemy:
		var to: Vector3 = targeted_enemy.global_position
		player.aim_dot.global_position = to
		player.turret_pivot.look_at(to, Vector3.UP, 0)
	else:
		# this stops the auto-firing
		player.aim_dot.global_position = player.global_position

func _find_closest_enemy(player: Player) -> Node3D:
	var min_enemy: Node3D = null
	var min_dist: float = default_aim_range + 1.0
	for n in get_tree().get_nodes_in_group("enemy"):
		# TODO: if dist squared is faster, we could square the min distance first and use that?
		var d := player.global_position.distance_to(n.global_position)
		if d < min_dist:
			min_dist = d
			min_enemy = n
	return min_enemy
