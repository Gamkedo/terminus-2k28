extends Enemy

var speed := 2.0
var drift_time := 1.5

var direction := Vector3.ZERO
var time_left := 0.0

var attack_power: float = 10.00
var attack_timer_max: float = 1.00 ## attack cooldown timer in seconds
var attack_timer: float = attack_timer_max

@onready var graphic_toward := $BillboardFront
@onready var graphic_away := $BillboardBack
@onready var collision_area: Area3D = $Area3D

func _ready():
	pick_new_direction()

	collision_area.body_entered.connect(_collision_detected)

func _process(delta):
	#time_left -= delta
	if time_left <= 0:
		pick_new_direction()

	_map_bb_prevention()
	global_position += direction * speed * delta

	if attack_timer > 0:
		attack_timer -= delta
	else:
		for body: Node3D in collision_area.get_overlapping_bodies():
			_collision_detected(body)

func pick_new_direction():
	var angle = randf_range(0.0, 2.0*PI)
	var dir := Vector2.from_angle(angle)
	direction = Vector3(dir.x, 0, dir.y)

	flip_graphics()

	time_left = drift_time

func _collision_detected(body: Node3D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.reduce_health(attack_power)
		attack_timer = attack_timer_max


## Hopefully prevents the unit from leaving the world.  Reflects the direction across the boundary normal.
func _map_bb_prevention():
	var limits: Dictionary[String, float] = GameGlobal.world_boundaries.get_world_limits()
	
	if global_position.x > limits["+x"] or global_position.x < limits["-x"] or global_position.z > limits["+z"] or global_position.z < limits["-z"]:
		direction = direction.length() * global_position.direction_to(Vector3(0, 1, 0))
		flip_graphics()

# toggle which graphic to show, moving towards or away from camera
#  Should be called every time we change direction
func flip_graphics() -> void:
	Utils.apply_billboard_graphics(graphic_toward, graphic_away, direction)
