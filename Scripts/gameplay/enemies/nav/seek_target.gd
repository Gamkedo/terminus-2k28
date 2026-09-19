class_name SeekTarget extends Node

@export var reaction_time_min:float = 0.1
@export var reaction_time_max:float = 1.5
var reaction_time := randf_range(reaction_time_min, reaction_time_max)

# as a percentage (0.0-1.0) what % distance to player to target in rand dir
# helps reduce clustering so they're harder to circle strafe or herd
@export var rand_offset_min:float = 0.05
@export var rand_offset_max:float = 0.6
var rand_offset := randf_range(rand_offset_min, rand_offset_max)


@export
var target_nav_dist_threshold:float = 1.0

@export
var enemy:Enemy

@export
var perception_component:PerceptionComponent

@export
var navigation_component:NavigationComponent

@onready var _update_timer: Timer = $UpdateTimer

var _target:Node3D
var _target_is_visible:bool
var _last_target_position:Vector3 = Vector3.INF

func _ready() -> void:
	assert(enemy)
	assert(perception_component)
	assert(navigation_component)
	
	perception_component.perceive_begin.connect(_on_perceive_begin)
	perception_component.perceive_end.connect(_on_perceive_end)
	
	_update_timer.wait_time = reaction_time
	_update_timer.timeout.connect(_on_timer_timeout)
		
func _on_perceive_begin(target:Node3D) -> void:
	print_debug("%s: Started seeing %s" % [name, target.name])

	if target != _target:
		_target_is_visible = false
		_last_target_position = Vector3.INF
		_target = target
		_update_timer.stop()
		
	if not _target_is_visible:
		_update_timer.start()
		return
	
func _on_perceive_end(target:Node3D) -> void:
	print_debug("%s: Stopped seeing %s" % [name, target.name])

	if target != _target:
		return
		
	_target_is_visible = false
	_update_timer.stop()
	
func _on_timer_timeout() -> void:
	_target_is_visible = true
	
	var dist = _target.global_position.distance_to(enemy.global_position)
	var rand_angle = randf_range(0, TAU)
	var rand_offset = randf_range(1, rand_offset*dist)
	var rand_dest = Vector2.from_angle(rand_angle) * rand_offset
	var target_pos:Vector3 = _target.global_position + Vector3(rand_dest.x, 0, rand_dest.y)

	# var target_pos:Vector3 = _target.global_position
	
	if target_pos.distance_squared_to(enemy.global_position) < target_nav_dist_threshold * target_nav_dist_threshold:
		return
	
	_last_target_position = target_pos
	navigation_component.set_target(target_pos)
