extends Weapon

@export var min_projectiles: int = 5
@export var max_projectiles: int = 10
@export var ramp_up: float = 1.15
@export var ramp_down: float = 5.
@export_range(0.0, 100.) var spawn_range: float = 15.

var bolts_to_shoot: int = 0
func fire(_pos: Vector3, _rot: Vector3) -> void:
	reload_time = fire_rate
	bolts_to_shoot += round(randf_range(min_projectiles, max_projectiles) * ramp_up_multiplier)
	ramp_up_multiplier += ramp_up

var ramp_up_multiplier: float = 0.
func _process(delta: float) -> void:
	super(delta)
	ramp_up_multiplier = max(ramp_up_multiplier - ramp_down * delta, 0.)
	if 0 < bolts_to_shoot:
		var projectile: LightningBolt = projectile_scene.instantiate() as LightningBolt
		projectile.lightning_source = self
		projectile.intended_position = global_position + Vector3((randf() - 0.5) * 2. * spawn_range, 0., (randf() - 0.5) * 2. * spawn_range)
		get_tree().current_scene.add_child(projectile)
		bolts_to_shoot -= 1
		AudioStreamManager.play_sfx("res://Sound Effects/Electricity/electricity_one_shot_v2.wav", AudioStreamManager.PlaybackMode.RANDOM_PITCH)
