extends Weapon
class_name Shotgun

@export var min_projectiles := 4
@export var max_projectiles := 10
@export_range(0.0, PI) var spread := 0.4

func fire(pos, rot) -> void:
	reload_time = fire_rate
	for _i in randi_range(min_projectiles, max_projectiles):
		var projectile := projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = pos
		projectile.global_rotation = rot
		projectile.rotate_y(randf_range(-spread, spread)) # random spread
	AudioStreamManager.play_sfx(sound_effect_path, AudioStreamManager.PlaybackMode.RANDOM_PITCH)
