## Fire a continuous laser beam
extends Weapon

## How long the beam lasts per fire
@export var beam_dur: float = 1.0

## Store current beam projectile
var beam_proj: Node3D = null

## Cache player hand spots where lasers are fired from
var laser_spots: Array[Node3D]
## Keep track of currently active firing spot
var active_laser_spot = -1

## Timer for how long beam interval update happens
var beam_timer: float = 0.0

func _ready() -> void:
	super._ready()
	assert(beam_dur <= fire_rate, "Beam duration must be less than reload time")

func _process(delta: float) -> void:
	super._process(delta)
	
	# Update beam to track player firing spots
	if active_laser_spot > -1 and beam_proj != null:
		var cur_aim_spot = laser_spots[active_laser_spot]
		beam_proj.global_position = cur_aim_spot.global_position
		var aim_target = cur_aim_spot.global_position - cur_aim_spot.get_global_transform_interpolated().basis.z
		beam_proj.look_at(aim_target, get_viewport().get_camera_3d().global_position - global_position)
	
	# Destroy beam once it is done firing
	beam_timer += delta
	if beam_timer >= beam_dur:
		beam_timer = 0.0
		if beam_proj: beam_proj.queue_free()
		beam_proj = null

func fire(pos: Vector3, rot: Vector3) -> Array[Node3D]:
	# Init fill of beam shot spots
	if laser_spots.size() == 0:
		laser_spots = GameGlobal.player_ref.get_shot_spots()
	
	# Manually check which hand we're currently firing from
	var proj_arr = super.fire(pos, rot)
	assert(proj_arr.size() <= 1)
	beam_proj = proj_arr[0]
	for i in range(laser_spots.size()):
		if (laser_spots[i].global_position - pos).length_squared() < 0.02:
			active_laser_spot = i
			break
	beam_timer = 0.0
	return proj_arr
