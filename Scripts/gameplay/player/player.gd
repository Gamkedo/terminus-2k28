extends CharacterBody3D

class_name Player

# parts of this code began from the educational example available here:
# https://www.youtube.com/watch?v=OVLJs3QjvR8
# https://github.com/learnictnow/godot-twin-stick-shooter/
# we've found grounding a code in a short, simple tutorial can make a game easier for
# teammates newer to an engine to join since they can easily catch up on the gist

# constants
const SPEED: float = 5.0
const FIRE_RATE: float = 0.2

# internal variables
var last_direction: Vector3 = Vector3.FORWARD
var reload_time: float = 0.0
var alternate_cannon_left: bool = true
var return_to_menu_delay: float = 2.0

var health_max: float = 100.00
var health_current: float = health_max
var has_died: bool = false

var already_rescued: bool = false

# exposed/tunable variables
@export var rotation_speed: float = 2
@export var aim_dead_zone: float = 0.01
@export var default_aim_range: float = 240
@export var auto_fire: bool = false

# external references
@onready var camera: Camera3D = get_viewport().get_camera_3d()
const LASER_TSCN: PackedScene = preload("res://Scenes - Objects/laser_bolt.tscn")
@export var follow_cam_move_to: Marker3D
@export var follow_cam_point_at: Node3D
var aim_componant: AimComponent
var weapons_manager: WeaponsManager

# internal references
@onready var legs: Node = $Legs
@onready var turret: Node = %Turret
@onready var turret_pivot: Node = %TurretPivot
@onready var muzzleA: Node = %FireFromA
@onready var muzzleB: Node = %FireFromB
@onready var aim_dot: Node3D = $AimDot
@onready var aim_ray_cast_3d: RayCast3D = %AimRayCast3D
@onready var death_explosion: AnimatedSprite3D = $DeathExplosion
@onready var death_explosion_particles: CPUParticles3D = $DeathExplosionParticles

# signals

signal health_reduced(amount: float)
signal health_gained(amount: float)
signal health_at_max ## health completely full

func _ready() -> void:
	GameGlobal.player_ref = self
	if camera.has_method("set_player"): # not currently needed in all scenes
		camera.set_player(self)
	
func _process(delta: float) -> void:
	if already_rescued:
		return
	
	reload_time -= delta

	handle_aiming(delta)

	if auto_fire and not aim_dot.global_position.is_equal_approx(global_position) and weapons_manager.can_fire():
		fire()
	if Input.is_action_pressed("fire") and weapons_manager.can_fire():
		fire()
	# if Input.is_action_pressed("ui_cancel"):
	# 	get_tree().change_scene_to_file("res://level_menu.tscn")

func fire() -> void:
	if alternate_cannon_left:
		weapons_manager.fire(muzzleA.global_position, muzzleA.global_rotation)
	else:
		weapons_manager.fire(muzzleB.global_position, muzzleB.global_rotation)
	alternate_cannon_left = !alternate_cannon_left

func _physics_process(delta: float) -> void:
	if already_rescued:
		return

	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")

	# negative z since that's forward for godot
	var cam_forward := -camera.global_basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()

	var cam_right := camera.global_basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()

	# reminder we're subtracting cam_forward due the negative direction for godot up/down inputs
	var direction := (cam_right * input_dir.x - cam_forward * input_dir.y).normalized()

	if direction:
		last_direction = direction
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	legs.rotation.y = lerp_angle(legs.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)

	move_and_slide()


func reduce_health(amount: float) -> void:
	if amount > health_current:
		amount = health_current

	health_current -= amount

	health_reduced.emit(amount)

	if health_current <= 0.0:
		if not has_died:
			has_died = true
			_on_death.call_deferred()
	else:
		# TODO: maybe someone can make a sound that's more purpose-built for this
		AudioStreamManager.play_sfx("res://Sound Effects/UI/UI_rumble.wav", AudioStreamManager.PlaybackMode.RANDOM_PITCH)
		ScreenVFX.shake(ScreenVFX.SHORT, ScreenVFX.TREMOR)
		ScreenVFX.flash(ScreenVFX.SHORT, ScreenVFX.TREMOR, ScreenVFX.Flash.BLAND)

	GameLogger.debug("Health: %.2f / %.2f" % [health_current, health_max])

func _on_death() -> void:
	death_explosion.show()
	death_explosion.play("default")
	death_explosion_particles.emitting = true
	ScreenVFX.slomo(ScreenVFX.MID, ScreenVFX.QUAKE)
	ScreenVFX.shake(ScreenVFX.LONG, ScreenVFX.QUAKE)
	ScreenVFX.flash(ScreenVFX.LONG, ScreenVFX.TREMOR, ScreenVFX.Flash.STARK)
	AudioStreamManager.play_sfx("res://Sound Effects/Explosions/explosion_4.wav")
	await AudioStreamManager.fade_out_music(return_to_menu_delay).finished
	GameGlobal.game_over.emit()


func gain_health(amount: float) -> void:
	if health_current + amount > health_max:
		amount = health_max - health_current

	health_current += amount

	health_gained.emit(amount)

	if health_current == health_max:
		health_at_max.emit()

	GameLogger.debug("Health: %.2f / %.2f" % [health_current, health_max])

func rescue_pickup() -> void:
	visible = false
	auto_fire = false
	already_rescued = true

func handle_aiming(delta: float) -> void:
	if aim_componant:
		aim_componant.handle_aiming(self, delta)

func get_shot_spots() -> Array[Node3D]:
	var shot_spots: Array[Node3D]
	shot_spots.push_back(muzzleA)
	shot_spots.push_back(muzzleB)
	return shot_spots
