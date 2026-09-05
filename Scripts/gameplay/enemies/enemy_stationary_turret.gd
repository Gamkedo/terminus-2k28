## Turret that stands still and aims at player, firing projectiles. Intended for survivor mode.
extends Enemy

# Gun pivot to rotate shooty part up and down
@onready var gun_pivot = $TurretTopModel/TurretGunPivot
# Where to spawn bullet
@onready var shot_spot = $TurretTopModel/TurretGunPivot/ShotSpot
# Turret top to rotate left/right
@onready var turret_top = $TurretTopModel

## How frequently to fire
@export var refire: float = 1.5
## Projectile scene reference
@export var projectile_scene: PackedScene = null
## How far away from player we can aim and shoot
@export var activate_range: float = 50.0

# Timer to count up to refire
var shot_timer: float = 0.0

func _process(delta: float) -> void:
	# only aim at player if within range
	var target_diff: Vector3 = GameGlobal.player_ref.global_position - global_position
	if target_diff.length_squared() > pow(activate_range, 2.0): return
	
	# handle left/right rotation to look at player
	var target_ang: float = atan2(-target_diff.z, target_diff.x) - PI / 2.0
	turret_top.rotation.y = lerp_angle(turret_top.rotation.y, target_ang, 1.0)
	
	# Fire at player
	shot_timer += delta
	if shot_timer > refire:
		shot_timer = 0
		var projectile := projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = shot_spot.global_position
		projectile.global_rotation = shot_spot.global_rotation
