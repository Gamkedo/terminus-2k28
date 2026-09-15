extends Node

#################################################################
# Global VFX (screenshake etc) and shared constants.
# Common utility methods are also welcome here.
#################################################################

const SHAKE_SPEED = 1.6
const STRENGTH_MULTIPLIER = 2.0

# Intensity constants
const FREAK_OUT = 1.5
const QUAKE = 1.0
const TREMOR = 0.5

# Timing constants
const SHORT = 0.3
const MID = 0.7
const LONG = 1.0
const EXTENDED = 2.0

# Types of screen flash. See "flash" method below for details.
enum Flash { NONE, NEUTRAL, LIGHT, DARK, STARK, BLAND }


@onready var noise := FastNoiseLite.new()
var shake_strength: float = 0.0
var shake_decay: float = 1.0
var flash_tween: Tween

# allows the user to turn down shaking
var shake_volume_setting := 1.0
var slow_shaders_enabled := true

var baseline_bloom := 0.0 
var baseline_brightness := 1.0
var baseline_contrast := 1.0
var baseline_saturation := 1.0


func get_shake_volume() -> float:
	return shake_volume_setting


func set_shake_volume(value: float) -> void:
	shake_volume_setting = value


## Screen shake with optional controller shake
func shake(seconds = MID, intensity = QUAKE, controller_shake = true) -> void:
	var new_strength = intensity * STRENGTH_MULTIPLIER * shake_volume_setting
	if new_strength <= shake_strength or seconds <= 0.0:
		return
	shake_strength = new_strength
	shake_decay = new_strength / seconds

	var weak_vibes := 0.0
	var strong_vibes := 0.0
	if intensity > TREMOR:
		strong_vibes = clampf((intensity - 0.5) * 2.0, 0.0, 1.0)
	else:
		weak_vibes = clampf(intensity * 2.0, 0.0, 1.0)
	if controller_shake:
		Input.start_joy_vibration(0, weak_vibes, strong_vibes, seconds)


## Screen flash only
## NEUTRAL is only bloom. 
## LIGHT/DARK adds brightness.
## STARK and BLAND add saturation as well.
## We'll probably need to tweak these as the real art and lighting evolves.
func flash(seconds = MID, intensity = QUAKE, type = Flash.NEUTRAL) ->void:
	var env := _get_world_env()
	if env and type != Flash.NONE:
		if flash_tween and flash_tween.is_running():
			flash_tween.stop()
		flash_tween = create_tween()
		flash_tween.set_ease(Tween.EASE_IN)
		#flash_tween.set_parallel(true)
		env.glow_bloom = intensity
		match type:
			Flash.LIGHT:
				env.adjustment_brightness = 1.0 + 2.0 * intensity
			Flash.DARK:
				env.glow_bloom = 0.0 # bloom doesn't look nice with this one
				env.adjustment_brightness = 1.0 - intensity * 1.2
			Flash.STARK:
				env.adjustment_contrast = 1.0 + intensity * 0.5
				env.adjustment_saturation = 1.0 + intensity * 0.5
			Flash.BLAND:
				env.adjustment_saturation = 1.0 - intensity
		flash_tween.tween_property(env, "glow_bloom", baseline_bloom, seconds)
		flash_tween.parallel().tween_property(env, "adjustment_brightness", baseline_brightness, seconds)
		flash_tween.parallel().tween_property(env, "adjustment_contrast", baseline_contrast, seconds)
		flash_tween.parallel().tween_property(env, "adjustment_saturation", baseline_saturation, seconds)


var slomo_tween: Tween
func slomo(seconds = MID, intensity = QUAKE) -> Tween:
	Engine.time_scale = lerpf(1.0, 0.1, intensity)
	return tween_time_scale(1.0, seconds)


func tween_time_scale(value: float, seconds = MID) -> Tween:
	if slomo_tween and not slomo_tween.finished:
		slomo_tween.stop()
	slomo_tween = get_tree().create_tween()
	slomo_tween.set_ease(Tween.EASE_IN_OUT)
	slomo_tween.set_trans(Tween.TRANS_SINE)
	slomo_tween.tween_property(Engine, "time_scale", value, seconds)
	return slomo_tween


## Fade the whole screen or a single node in or out
# TODO: this doesn't actually fade the title screen in and out, which is weird
# It's because it's a canvas layer, which isn't affected by the modulate on the container or the root node
# and doesn't have a modulate property of its own.
func fade(seconds = MID, node = null, to_color = Color.TRANSPARENT) -> Tween:
	if not node:
		node = get_tree().root
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate", to_color, seconds)
	return tween


## Fade a given node to transparency or fade the whole screen to black
func fade_out(seconds = MID, node = null) -> Tween:
	return fade(seconds, node, Color.TRANSPARENT if node else Color.BLACK)


## Fade a given node (or the whole screen) from its current modulate value to white
func fade_in(seconds = MID, node = null):
	return fade(seconds, node, Color.WHITE)


func _get_world_env() -> Environment:
	var we = get_tree().get_first_node_in_group("world_environment")
	if we and we is WorldEnvironment:
		return we.environment
	we = get_viewport().get_camera_3d().environment
	return we

func _process(delta: float) -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if not cam: return
	if shake_strength > 0.0:
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)
		var noise_idx := Time.get_ticks_msec() * SHAKE_SPEED
		var shake_offset := Vector2(
			noise.get_noise_2d(1, noise_idx),
			noise.get_noise_2d(100, noise_idx),
		)
		cam.h_offset = shake_offset.x * shake_strength
		cam.v_offset = shake_offset.y * shake_strength
