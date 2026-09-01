extends Node
class_name Weapon

@export var sound_effect_path: String
@export var projectile_scene: PackedScene
@export_range(0.01, 2.0, 0.01) var fire_rate := 0.2

var reload_time := 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	reload_time -= delta

func fire(pos: Vector3, rot: Vector3) -> void:
	reload_time = fire_rate
	var projectile := projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = pos
	projectile.global_rotation = rot
	AudioStreamManager.play_sfx(sound_effect_path, AudioStreamManager.PlaybackMode.RANDOM_PITCH)

func can_fire() -> bool:
	return reload_time <= 0.0
