class_name ImmersiveAimComponent extends AimComponent


@export var y_target: Node3D
@export var x_target: Node3D
@export var h_sense: float = 10.0
@export var v_sense: float = 7.0
@export var sensitivity: float = 1
## this is to make the other sensitivity values more human readable. They are divided by this
@export var sense_modifier: float = 100.0
var real_sensitivity: float:
	get:
		return sensitivity / sense_modifier
@export var active: bool = true

@export var invert_h: bool = false
@export var invert_v: bool = false


func handle_aiming(player: Player, delta: float) -> void:
	if not active:
		return

	var h_amount = Input.get_axis("aim_right", "aim_left")
	if invert_h:
		h_amount *= -1

	player.turret_pivot.rotate_y(h_amount * real_sensitivity * h_sense)
	
	var v_amount = Input.get_axis("aim_down", "aim_up")
	if invert_v:
		v_amount *= -1
	player.turret.rotate_x(v_amount * real_sensitivity * v_sense)
