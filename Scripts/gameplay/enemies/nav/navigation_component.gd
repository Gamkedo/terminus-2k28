class_name NavigationComponent extends Node3D

signal target_selected(target:Vector3)
signal target_reached(target:Vector3)
signal target_canceled(target:Vector3)


@onready 
var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export
var movement_handler:NavigationMovementHandler

@export
var enable_avoidance:bool = true

var physics_delta: float
var _enemy:Enemy

var _target_position:Vector3 = Vector3.INF
var _target_path_position:Vector3
var _target_projected:bool
var _last_valid_path_pos: Vector3 = Vector3.ZERO

var enabled:bool:
	set(value):
		enabled = value
		
		if value and enable_avoidance:
			navigation_agent.avoidance_enabled = true
		else:
			navigation_agent.avoidance_enabled = false
		
		movement_handler.active = false	
		set_physics_process(enabled)
		
func _ready() -> void:
	assert(movement_handler)
	_enemy = movement_handler.enemy
	assert(_enemy)
		
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	navigation_agent.navigation_finished.connect(_on_navigation_finished)
	navigation_agent.path_changed.connect(_on_navigation_agent_path_changed)
	
	navigation_agent.max_speed = movement_handler.get_max_movement_speed()
	
	enabled = false
	_validate_initial_position.call_deferred()

func _validate_initial_position() -> void:
	var navigation_map: RID = navigation_agent.get_navigation_map()
	
	while true:
		if NavigationServer3D.map_get_iteration_id(navigation_map) > 0:
			break
		await get_tree().physics_frame
		
	var global_spawn_pos: Vector3 = _enemy.global_position
	var closest_point_global: Vector3 = NavigationServer3D.map_get_closest_point(navigation_map, global_spawn_pos)
	
	if global_spawn_pos.distance_to(closest_point_global) > 0.05:
		_enemy.global_position = closest_point_global
		
func set_target(target: Vector3):
	if _target_position != Vector3.INF:
		target_canceled.emit(_target_position)
	
	_target_projected = false
	_target_position = target
	_target_path_position = target
	
	navigation_agent.set_target_position(target)
	enabled = true
	
	target_selected.emit(_target_position)

func stop() -> void:
	if not enabled:
		return
	
	if OS.is_stdout_verbose():
		print_debug("%s(%s) - Navigation to canceled" % [_enemy.name, name, _target_position])
	
	enabled = false
	if _target_position != Vector3.INF:
		target_canceled.emit(_target_position)
		
func _physics_process(delta):
	# Save the delta for use in _on_velocity_computed.
	physics_delta = delta
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return
	
	var closest_point: Vector3 = NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), _enemy.global_position)
	_enemy.bool_passing_through_wall = closest_point.distance_to(_enemy.global_position) > 0.01
	if _enemy.bool_passing_through_wall:
		_enemy.global_position = closest_point
	
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = _enemy.global_position.direction_to(next_path_position) * movement_handler.get_current_movement_speed()
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
func _on_velocity_computed(safe_velocity: Vector3) -> void:
	var navigation_map: RID = navigation_agent.get_navigation_map()
	var horizontal_velocity: Vector3 = Vector3(safe_velocity.x, 0, safe_velocity.z)
	var projected_pos: Vector3 = _enemy.global_position + (horizontal_velocity * physics_delta)
	
	var closest_point: Vector3 = NavigationServer3D.map_get_closest_point(navigation_map, projected_pos)
	var flat_projected: Vector2 = Vector2(projected_pos.x, projected_pos.z)
	var flat_closest: Vector2 = Vector2(closest_point.x, closest_point.z)
	
	var final_velocity: Vector3 = safe_velocity
	if flat_projected.distance_to(flat_closest) > 0.1:
		var current_closest: Vector3 = NavigationServer3D.map_get_closest_point(navigation_map, _enemy.global_position)
		var return_dir: Vector3 = (current_closest - _enemy.global_position).normalized()
		final_velocity = return_dir * movement_handler.get_current_movement_speed()
		
	movement_handler.active = true
	movement_handler.move(final_velocity, physics_delta)
	
func _on_navigation_finished() -> void:
	if navigation_agent.is_target_reached():
		_on_target_reached()
	else:
		stop()

func _on_navigation_agent_path_changed() -> void:
	if _target_projected:
		return
		
	# Update current target with nav mesh projected target position
	# Keep original target position for comparison to original requested target when move completes or is canceled
	# get_final_position can cause a path to be generated (per Godot source code) which would result in infinite recursion
	# as the signal callback called again so be sure to set the guard flag BEFORE calling that function
	_target_projected = true
	_target_path_position = navigation_agent.get_final_position()
	
func _on_target_reached() -> void:
	if OS.is_stdout_verbose():
		print_debug("%s(%s) - Navigation to %s complete" % [_enemy.name, name, _target_position])

	enabled = false

	if _target_position != Vector3.INF:
		var reached_pos := _target_position
		_target_position = Vector3.INF
		target_reached.emit(reached_pos)
