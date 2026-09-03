extends Node

signal round_started(round_number)
signal round_complete(round_number)

var round_number : int = 0

func _ready() -> void:
	round_started.emit()
	_start_new_round()


func _start_new_round() -> void:
	round_number + 1
	_spawn_enemies()


func _spawn_enemies() -> void:
	pass
	# idea is to create an easily modifiable component for a level designer
	# to select an enemy type, a number of that enemy type and time in seconds
	# between each spawn / batch


func _end_round() -> void:
	round_complete.emit()
	await get_tree().create_timer(2.0).timeout
	_start_new_round()
	
	
