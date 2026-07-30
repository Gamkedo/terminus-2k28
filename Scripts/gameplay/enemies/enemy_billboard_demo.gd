extends Node3D

var speed := 2.0
var drift_time := 1.5

var direction := Vector3.ZERO
var time_left := 0.0

func _ready():
	pick_new_direction()

func _process(delta):
	time_left -= delta
	if time_left <= 0:
		pick_new_direction()
	global_position += direction * speed * delta

func pick_new_direction():
	var angle = randf_range(0.0, 2.0*PI)
	var dir := Vector2.from_angle(angle)
	direction = Vector3(dir.x, 0, dir.y)
	time_left = drift_time
