extends Node3D

var track_player: Player
var relative_offset: Vector3

func set_player(player):
	track_player = player
	relative_offset = global_position-track_player.global_position

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(
			track_player.global_position + relative_offset,
			5.0 * delta)
