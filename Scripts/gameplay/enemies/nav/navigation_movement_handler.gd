@abstract
class_name NavigationMovementHandler extends Node

@export
var enemy:Enemy

var active:bool

@abstract
func get_current_movement_speed() -> float

@abstract
func get_max_movement_speed() -> float

@abstract
func move(in_velocity:Vector3, physics_delta:float) -> void
