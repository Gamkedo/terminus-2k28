extends Node3D

var track_player: Player

func set_player(player):
	track_player = player

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(track_player.follow_cam_move_to.global_position,
			5.0 * delta)
	var smooth_look = global_transform.looking_at(
		track_player.follow_cam_point_at.global_position,Vector3.UP).basis.get_rotation_quaternion()

	quaternion = quaternion.slerp(smooth_look, 5.0 * delta)


func get_aim_center() -> Vector2:
	return get_viewport().get_visible_rect().size / 2
