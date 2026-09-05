## Enemy that can fire projectiles. Intended for arcade mode.

extends "res://Scripts/gameplay/enemies/enemy_billboard_flip.gd"

@export var refire: float = 2.5
@export var projectile_scene: PackedScene = null

@onready var shot_spot = $ShotPivot/ShotSpot
@onready var shot_pivot = $ShotPivot

var shot_timer: float = 0.0

func _process(delta: float) -> void:
	super._process(delta)
	shot_timer += delta
	if shot_timer >= refire:
		shot_timer = 0.0
		var projectile = projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)
		shot_pivot.look_at(GameGlobal.player_ref.global_position)
		projectile.global_position = shot_spot.global_position
		projectile.global_rotation = shot_spot.global_rotation
