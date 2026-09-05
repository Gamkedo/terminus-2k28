extends Weapon

@export var min_projectiles := 5
@export var max_projectiles := 10
@export_range(0.0, 100.) var spawn_range := 15.

func fire(pos: Vector3, _rot: Vector3) -> Array[Node3D]:
	reload_time = fire_rate
	var proj_arr: Array[Node3D]
	for _i in randi_range(min_projectiles, max_projectiles):
		var projectile := projectile_scene.instantiate() as LightningBolt
		projectile.lightning_source = self
		projectile.intended_position = pos + Vector3((randf() - 0.5) * 2. * spawn_range, 0., (randf() - 0.5) * 2. * spawn_range)
		get_tree().current_scene.add_child(projectile)
		proj_arr.push_back(projectile)
	AudioStreamManager.play_sfx("res://Sound Effects/Electricity/electricity_one_shot_test.wav", AudioStreamManager.PlaybackMode.RANDOM_PITCH)
	return proj_arr
