class_name SeekTarget extends Node

@export
var reaction_time:float = 0.5

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
	var target_pos:Vector3 = _target.global_position
	if target_pos.distance_squared_to(enemy.global_position) < target_nav_dist_threshold * target_nav_dist_threshold:
		return
	
	_last_target_position = target_pos
	navigation_component.set_target(target_pos)
