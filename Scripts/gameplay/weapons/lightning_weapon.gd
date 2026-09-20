extends Weapon

@export var cache_fire_on_start:bool = false

@export var light_fake: Node3D
@export var light_fake_travel_length: float = 0.05
@export var min_projectiles: int = 5
@export var max_projectiles: int = 10
@export var ramp_up: float = 1.15
@export var ramp_down: float = 5.
@export var flicker_interval: float = 0.5
@export_range(1.0, 100.) var spawn_range: float = 15.

func _ready() -> void:
	if cache_fire_on_start:
		fire(global_position, Vector3.ZERO)

var bolts_to_shoot: int = 0
func fire(_pos: Vector3, _rot: Vector3) -> void:
	reload_time = fire_rate
	if bolts_to_shoot == 0: time_to_flicker = 0
	bolts_to_shoot = min(max_projectiles, bolts_to_shoot + max(round(randf_range(min_projectiles, max_projectiles) * ramp_up_multiplier), 1))
	ramp_up_multiplier += ramp_up
	if ramp_up_multiplier > 1.0:
		ramp_up_multiplier = 1.0

@onready var light_fake_original_position = light_fake.position #TechDebt this can not handle conditionally if the light fake isn't set
var time_to_flicker: float = flicker_interval
var ramp_up_multiplier: float = 0.
func _process(delta: float) -> void:
	super(delta)
	ramp_up_multiplier = max(ramp_up_multiplier - ramp_down * delta, 0.)
	AudioStreamManager.lightning_loop_update(ramp_up_multiplier > 0.3, power_level)
	# lightning_loop_player.pitch_scale = randf_range(0.9,1.1) will shift based on upgrade level

	
	if 0 < bolts_to_shoot:
		time_to_flicker -= delta
		if time_to_flicker < 0.:
			time_to_flicker = flicker_interval
			if light_fake:
				light_fake.visible = not light_fake.visible
				if light_fake.visible:
					light_fake.position = light_fake_original_position + Vector3(
						randfn(0., light_fake_travel_length),
						randfn(0., light_fake_travel_length),
						randfn(0., light_fake_travel_length),
					)
					create_tween().tween_method(func(w: float): light_fake.get_active_material(0).albedo_color.a = sin(w), 0., PI, time_to_flicker)
		var projectile: LightningBolt = projectile_scene.instantiate() as LightningBolt
		projectile.lightning_source = self
		projectile.intended_position = global_position + Vector3((randf() - 0.5) * 2. * spawn_range, 0., (randf() - 0.5) * 2. * spawn_range)
		get_tree().current_scene.add_child(projectile)
		bolts_to_shoot -= 1
		# if cache_fire_on_start == false:
		#	AudioStreamManager.play_sfx("res://Sound Effects/Electricity/electricity_one_shot_v2.wav", AudioStreamManager.PlaybackMode.RANDOM_PITCH)
	elif light_fake: light_fake.visible = false
