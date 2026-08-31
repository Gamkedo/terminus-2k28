extends Enemy

var speed := 2.0
var drift_time := 1.5

var direction := Vector3.ZERO
var time_left := 0.0

var attack_power: float = 10.00
var attack_timer_max: float = 1.00 ## attack cooldown timer in seconds
var attack_timer: float = attack_timer_max

var rotation_speed := 5

@onready var collision_area: Area3D = $Area3D

func _ready():
	pick_new_direction()

	collision_area.body_entered.connect(_collision_detected)

func _process(delta):
	time_left -= delta
	if time_left <= 0:
		pick_new_direction()
	global_position += direction * speed * delta
	rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * rotation_speed)

	if attack_timer > 0:
		attack_timer -= delta
	else:
		for body: Node3D in collision_area.get_overlapping_bodies():
			_collision_detected(body)

func pick_new_direction():
	var my_flat_position = Vector2(global_position.x, global_position.z)
	var player_flat_position = Vector2(GameGlobal.player_ref.global_position.x, GameGlobal.player_ref.global_position.z)
	var angle = (player_flat_position - my_flat_position).angle()
	var dir := Vector2.from_angle(angle)
	direction = Vector3(dir.x, 0, dir.y)
	time_left = drift_time

func _collision_detected(body: Node3D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.reduce_health(attack_power)
		attack_timer = attack_timer_max
