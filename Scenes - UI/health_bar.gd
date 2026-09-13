extends Control

@onready var background: Control = $Background
@onready var active_bar: Control = $ActiveBar
@onready var hurt_particles: GPUParticles2D = $HurtParticles

@export var tween_seconds: float = 0.2
@export var intensity_on_flash: float = 2.5
@export var growth_on_flash: float = 1.1

var width_ratio: float
var tween: Tween
var cur_value: float

func _ready() -> void:
	var p: Player = GameGlobal.player_ref
	p.health_reduced.connect(_on_health_lost)
	p.health_gained.connect(_on_health_added)
	width_ratio = size.x / p.health_max
	cur_value = p.health_current
	hurt_particles.emitting = false
	hurt_particles.one_shot = true
	_set_displayed_value.call_deferred(cur_value)

func _on_health_added(_v: float) -> void:
	_tween_to_value(GameGlobal.player_ref.health_current, true)

func _on_health_lost(_v: float) -> void:
	_tween_to_value(GameGlobal.player_ref.health_current, true)
	hurt_particles.restart()

func _tween_to_value(v: float, flash = false) -> void:
	if tween and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_method(_set_displayed_value, cur_value, v, tween_seconds)
	if flash:
		modulate = Color(intensity_on_flash, intensity_on_flash, intensity_on_flash, 1.0)
		offset_transform_scale = Vector2.ONE * growth_on_flash
		tween.parallel().tween_property(self, "modulate", Color.WHITE, tween_seconds)
		tween.parallel().tween_property(self, "offset_transform_scale", Vector2.ONE, tween_seconds)

func _set_displayed_value(v: float) -> void:
	var max_health := GameGlobal.player_ref.health_max
	background.size.x = width_ratio * max_health
	active_bar.size.x = background.size.x * v / max_health
	hurt_particles.position.x = active_bar.size.x
	cur_value = v
