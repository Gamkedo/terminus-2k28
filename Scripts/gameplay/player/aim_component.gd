class_name AimComponent extends Node

@export var aim_dead_zone := 0.01
@export var default_aim_range := 240


func _ready() -> void:
	var player := get_parent() as Player
	if player:
		player.aim_componant = self


func handle_aiming(player: Player) -> void:
	joypad_aim(player) # This will override mouseaim IF the joystick vector is greater than the deadzone
	look_at_cursor(player)


func look_at_cursor(player: Player):
	var target_plane_mouse := Plane(Vector3.UP, player.position.y)
	var ray_length := 1000
	var mouse_position := get_viewport().get_mouse_position()
	var from := player.camera.project_ray_origin(mouse_position)
	var to := from + player.camera.project_ray_normal(mouse_position) * ray_length

	var cursor_position_on_plane = target_plane_mouse.intersects_ray(from, to)

	if cursor_position_on_plane:
		player.aim_dot.global_position = cursor_position_on_plane
		player.turret.look_at(cursor_position_on_plane, Vector3.UP, 0)
	else:
		player.aim_dot.global_position = to
		player.turret.look_at(to)


## Returns a Vector2 from the aim direction inputs
func get_joypad_aim_vector() -> Vector2:
	return Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down", aim_dead_zone)


func joypad_aim(player: Player) -> void:
	var aim_vector = get_joypad_aim_vector()
	# return early if stick in dead zone
	if not aim_vector:
		return
	var aim_vector_3d = Vector3(aim_vector.x, 0, aim_vector.y) # TODO I need to center this on the turrent and then unproject it. that's why the aim point is drifting
	var turret_pos_2d = player.camera.unproject_position(player.turret.global_position)
	var aim_center = player.camera.unproject_position(player.turret.global_position)
	if player.camera.has_method("get_aim_center"):
		aim_center = player.camera.get_aim_center()
	get_viewport().warp_mouse(aim_center + aim_vector * default_aim_range)
