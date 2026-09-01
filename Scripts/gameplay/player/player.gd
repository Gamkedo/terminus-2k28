extends CharacterBody3D

class_name Player

# parts of this code began from the educational example available here:
# https://www.youtube.com/watch?v=OVLJs3QjvR8
# https://github.com/learnictnow/godot-twin-stick-shooter/
# we've found grounding a code in a short, simple tutorial can make a game easier for
# teammates newer to an engine to join since they can easily catch up on the gist

# constants
const SPEED := 5.0
const FIRE_RATE := 0.2

# internal variables
var last_direction := Vector3.FORWARD
var reload_time := 0.0
var alternate_cannon_left := true
var weapons: Array[Weapon] = []
var active_weapon = 0

var health_max: float = 100.00
var health_current: float = health_max

# exposed/tunable variables
@export var rotation_speed := 2
@export var aim_dead_zone := 0.01
@export var default_aim_range := 240

# external references
@onready var camera := get_viewport().get_camera_3d()
const LASER_TSCN := preload("res://Scenes - Objects/laser_bolt.tscn")
@export var follow_cam_move_to: Marker3D
@export var follow_cam_point_at: Node3D
var aim_componant

# internal references
@onready var legs := $Legs
@onready var turret := $Turret
@onready var muzzleA := $Turret/CannonA/FireFromA
@onready var muzzleB := $Turret/CannonB/FireFromB
@onready var aim_dot := $AimDot


# signals

signal health_reduced(amount)
signal health_gained(amount)
signal health_depleted ## zero or less health, death
signal health_at_max ## health completely full

func _ready() -> void:
	GameGlobal.player_ref = self
	if camera.has_method("set_player"): # not currently needed in all scenes
		camera.set_player(self)
	
	#set up weapons
	for child in get_children():
		if child is Weapon: weapons.append(child)
	
func _process(delta):
	reload_time -= delta

	handle_aiming()

	if Input.is_action_pressed("fire") and weapons[active_weapon].can_fire():
		fire()
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://level_menu.tscn")
	if Input.is_action_just_pressed("debug_cycle_weapon"):
		# Quick test for swapping weapons
		active_weapon += 1
		if active_weapon >= weapons.size():
			active_weapon = 0
		

func fire():
	if alternate_cannon_left:
		weapons[active_weapon].fire(muzzleA.global_position, muzzleA.global_rotation)
	else:
		weapons[active_weapon].fire(muzzleB.global_position, muzzleB.global_rotation)
	alternate_cannon_left = !alternate_cannon_left

func _physics_process(delta: float) -> void:
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
		health_depleted.emit()

	GameLogger.debug("Health: %.2f / %.2f" % [health_current, health_max])


func gain_health(amount: float) -> void:
	if health_current + amount > health_max:
		amount = health_max - health_current

	health_current += amount

	health_gained.emit(amount)

	if health_current == health_max:
		health_at_max.emit()

	GameLogger.debug("Health: %.2f / %.2f" % [health_current, health_max])


func handle_aiming() -> void:
	if aim_componant:
		aim_componant.handle_aiming(self)
