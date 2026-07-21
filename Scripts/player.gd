extends CharacterBody3D

# parts of this code began from the educational example available here:
# https://www.youtube.com/watch?v=OVLJs3QjvR8
# https://github.com/learnictnow/godot-twin-stick-shooter/
# we've found grounding a code in a short, simple tutorial can make a game easier for
# teammates newer to an engine to join since they can easily catch up on the gist

# constants
const SPEED = 5.0

# internal variables
var last_direction = Vector3.FORWARD

# exposed/tunable variables
@export var rotation_speed = 2

# external references
@onready var camera = get_viewport().get_camera_3d()
# internal references
@onready var legs = $Legs
@onready var turret = $Turret
@onready var aim_dot = $AimDot

func _ready() -> void:
	pass
	
func _process(delta):
	look_at_cursor()

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	
	# negative z since that's forward for godot
	var cam_forward = -camera.global_basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()

	var cam_right = camera.global_basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()
	
	# reminder we're subtracting cam_forward due the negative direction for godot up/down inputs
	var direction = (cam_right * input_dir.x - cam_forward * input_dir.y).normalized()
	
	if direction:
		last_direction = direction
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	legs.rotation.y = lerp_angle(legs.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)
	
	move_and_slide()

func look_at_cursor():
	var target_plane_mouse = Plane(Vector3(0,1,0), turret.global_position.y)
	var ray_length = 1000
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var cursor_position_on_plane = target_plane_mouse.intersects_ray(from, to)
	if cursor_position_on_plane:
		aim_dot.global_position = cursor_position_on_plane
		turret.look_at(cursor_position_on_plane, Vector3.UP, 0)
