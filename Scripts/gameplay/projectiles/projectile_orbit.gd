# Projectile that orbits something

extends "res://Scripts/gameplay/projectiles/laser_bolt.gd"

## How far away from object to orbit
@export var orbit_range := 3.0
## How fast to complete one cycle (in seconds)
@export var orbit_period := 1.0
## Set graphic_toward, if applicable
@export var graphic_toward: SpriteBase3D
## Set graphic_away, if applicable
@export var graphic_away: SpriteBase3D

var orbit_target: Node3D
var orbit_angle := 0.0
var orbit_spd: float

func _ready():
	super._ready()
	orbit_spd = (2.0 * PI) / orbit_period

func _physics_process(delta):
	# intentionally not calling parent func since we handle movement ourselves
	
	# orbit around orbit target, if it exists
	if orbit_target:
		orbit_angle += orbit_spd * delta
		var orbit_offset = Vector3(cos(orbit_angle), 0.2, sin(orbit_angle)) * orbit_range
		global_position = orbit_target.global_position + orbit_offset
		
		# update graphics if applicable (used for shield bot, which has billboard flip graphics)
		if graphic_toward and graphic_away:
			var orbit_dir = Vector3(-sin(orbit_angle), 0, cos(orbit_angle))
			Utils.apply_billboard_flip_graphics(graphic_toward, graphic_away, orbit_dir)

# call externally to set who to orbit, and optionally a start angle
#  (for even spacing of multiple orbiters, for example)
func set_orbit_target(target: Node3D, start_angle = 0.0) -> void:
	orbit_target = target
	orbit_angle = start_angle
