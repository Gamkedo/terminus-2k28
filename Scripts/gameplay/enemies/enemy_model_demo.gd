extends Enemy

@export var speed_min := 4.0
@export var speed_max := 4.0
var speed := randf_range(speed_min, speed_max)

@onready var graphic_toward = $BillboardFront
@onready var graphic_away = $BillboardBack

@export var drift_time := 1.5

var direction := Vector3.ZERO
var time_left := 0.0

var attack_power: float = 10.00
var attack_timer_max: float = 1.00 ## attack cooldown timer in seconds
var attack_timer: float = attack_timer_max

@export var rotation_speed := 5

@onready var collision_area: Area3D = $Area3D

@export
var nav_movement_handler:NavigationMovementHandler

func _ready():
	super._ready()
	
	pick_new_direction()
	
	enforce_boundary()

	collision_area.body_entered.connect(_collision_detected)

func _process(delta):
	if stun_time > 0.0:
		stun_time -= delta
		return
	
	# If navigation is active, then direction is handled by movement handler
	if not nav_movement_handler or not nav_movement_handler.active:
		time_left -= delta
		if time_left <= 0:
			pick_new_direction()
	global_position += direction * speed * delta
	rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * rotation_speed)

	Utils.apply_billboard_flip_graphics(graphic_toward, graphic_away, direction)
	
	enforce_boundary()

	if attack_timer > 0:
		attack_timer -= delta
	else:
		for body: Node3D in collision_area.get_overlapping_bodies():
			_collision_detected(body)

func pick_new_direction():	
	# Only seek the player if the movement handler is not in the scene
	if not nav_movement_handler:
		var my_flat_position = Vector2(global_position.x, global_position.z)
		var player_flat_position = Vector2(GameGlobal.player_ref.global_position.x, GameGlobal.player_ref.global_position.z)
		
		var angle = (player_flat_position - my_flat_position).angle()
		var dir := Vector2.from_angle(angle)
		direction = Vector3(dir.x, 0, dir.y)
	else:
		direction = _wander()
		
	time_left = drift_time

func _wander() -> Vector3:
	# randomly wander
	return Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()
	
func _collision_detected(body: Node3D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.reduce_health(attack_power)
		attack_timer = attack_timer_max

func death_explosion() -> void:
	if has_node("DeathExplosion") == null:
		generic_explode()
		return
	var death_group = get_node("DeathExplosion")
	var death_anim = death_group.get_node("BillboardFront")
	var death_explosion_particles = death_group.get_node("DeathExplosionParticles")
	death_anim.show()
	death_anim.play("default")
	death_explosion_particles.emitting = true
	
	ScreenVFX.slomo(ScreenVFX.SHORT, ScreenVFX.TREMOR)
	ScreenVFX.shake(ScreenVFX.SHORT, ScreenVFX.TREMOR)
	
	# to survive the parent being freed
	remove_child(death_group)
	get_tree().root.add_child(death_group)
	death_group.global_position = global_position
	
	graphic_toward.visible = false
	graphic_away.visible = false
	AudioStreamManager.play_sfx("res://Sound Effects/Explosions/explosion_4.wav")
	
