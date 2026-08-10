extends Node3D

var speed := 2.0
var drift_time := 1.5

var direction := Vector3.ZERO
var time_left := 0.0

var rotation_speed := 5

func _ready():
	pick_new_direction()

func _process(delta):
	time_left -= delta
	if time_left <= 0:
		pick_new_direction()
	global_position += direction * speed * delta
	rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * rotation_speed)

func pick_new_direction():
	var my_flat_position = Vector2(global_position.x, global_position.z)
	var player_flat_position = Vector2(GameGlobal.player_ref.global_position.x, GameGlobal.player_ref.global_position.z)
	var angle = (player_flat_position - my_flat_position).angle()	
	var dir := Vector2.from_angle(angle)
	direction = Vector3(dir.x, 0, dir.y)
	time_left = drift_time
