extends Weapon
class_name Shotgun

@export var min_projectiles := 4
@export var max_projectiles := 10
@export_range(0.0, PI) var spread := 0.4

func fire(pos, rot) -> Array[Node3D]:
	reload_time = fire_rate
	var proj_arr: Array[Node3D]
	for _i in randi_range(min_projectiles, max_projectiles):
		var projectile := projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = pos
		projectile.global_rotation = rot
		projectile.rotate_y(randf_range(-spread, spread)) # random spread
		proj_arr.push_back(projectile)
	AudioStreamManager.play_sfx(sound_effect_path, AudioStreamManager.PlaybackMode.RANDOM_PITCH)
	return proj_arr
