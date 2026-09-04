## Component to visually detect player using a standard combination of
## distance check (via area entered/left), cone check for angle, and line of sight check
class_name PerceptionComponent extends Node3D

## When perception is first noted
## It's up to the receiver to implement reaction time and start a timer to delay, if desired
signal perceive_begin(object:Node3D)

## When preception ends for the given object
signal perceive_end(object:Node3D)

class DetectionData:
	var body:Node3D
	var detected:bool
	
	func _init(in_body:Node3D) -> void:
		body = in_body
	
	func clear() -> void:
		detected = false
		
@onready var _detection_area: Area3D = %DetectionArea
@onready var _detection_shape: CollisionShape3D = %DetectionShape
@onready var _scan_timer: Timer = %ScanTimer

# Maps body instance id to state data for perception processing
var _detections:Dictionary[int, DetectionData]
var _ray_cast_params:PhysicsRayQueryParameters3D

@export
var enabled:bool = true:
	set(value):
		enabled = value
		_update_area_scan()

@export_flags_3d_physics
## Mask of what should be considered for perception
## Ideally player is on its own physics layer
var scanning_mask:int = 1:
	set(value):
		scanning_mask = value
		_update_area_scan()

## Mask for what blocks visibility
## Defaults to static obstacle (Layer 1)
@export_flags_3d_physics
var visibility_mask:int = 1:
	set(value):
		visibility_mask = value
		if _ray_cast_params:
			_ray_cast_params.collision_mask = value
			
## Max distance to perceive
@export
var max_distance:float = 25.0:
	set(value):
		max_distance = value
		_update_area_scan()


## Interval to scan for cone check and visibility check once inside the distance threshold
@export
var scan_interval:float = 0.2:
	set(value):
		scan_interval = value
		if _scan_timer:
			_scan_timer.wait_time = value

@export_range(0.1, 90.0, 0.1)
var cone_half_angle_deg:float = 60.0:
	set(value):
		cone_half_angle_deg = value
		_compute_cone_cos()
		
## Eyes of character of where to initiate the cone check and line of sight scans			
@export
var eyes:Node3D

## Whether the eyes node uses model front (+Z) convention or (-Z) Godot forward
## If scans go backwards you should flip
@export
var eyes_use_model_front:bool = false

## Group name of nodes positions to use on target for line of sight checks
## E.g. head, torso, feet
@export
var line_of_sight_target_group:StringName = ""

var _cone_cos:float

var eyes_forward:Vector3:
	get:
		return eyes.global_basis.z if eyes_use_model_front else -eyes.global_basis.z
	
var _debug_self:Node:
	get:
		return owner if owner else self


func _compute_cone_cos() -> void:
	_cone_cos = cos(deg_to_rad(cone_half_angle_deg))
	
func _ready() -> void:
	_ray_cast_params = PhysicsRayQueryParameters3D.new()
	_ray_cast_params.collide_with_areas = false
	_ray_cast_params.collide_with_bodies = true
	_ray_cast_params.collision_mask = visibility_mask

	var our_body:PhysicsBody3D = Utils.up_tree_with_type(eyes, PhysicsBody3D)
	if our_body:
		_ray_cast_params.exclude = [our_body.get_rid()]
	
	_update_area_scan()
	_compute_cone_cos()
	
	_scan_timer.wait_time = scan_interval
	
	if not eyes:
		push_warning("%s(%s): eyes node not configured - using first Node3D parent" % [_debug_self.name, name])
		eyes = owner as Node3D
		if not eyes:
			eyes = Utils.up_tree_with_type(self, Node3D)
		if not eyes:
			push_error("%s(%s): Could not derive eyes node from a parent 3d!" % [_debug_self.name, name])
	
func _update_area_scan() -> void:
	if not is_node_ready():
		return
		
	_detection_area.monitoring = enabled
	_detection_area.collision_mask = scanning_mask
	
	var shape:SphereShape3D = _detection_shape.shape
	if max_distance >= 0 and not is_equal_approx(shape.radius, max_distance):
		# Duplicate as resources are shared
		shape = shape.duplicate()
		shape.radius = max_distance
		_detection_shape.shape = shape
		
func _on_scan_timer_timeout() -> void:
	if not _detections:
		return
	
	if OS.is_stdout_verbose():
		print_debug("%s(%s): Checking %s bodies" % [_debug_self.name, name, _detections.size()])
	
	var invalid_ids:PackedInt64Array
	
	for id in _detections:
		if not is_instance_id_valid(id):
			invalid_ids.push_back(id)
			continue
		var detection_data:DetectionData = _detections[id]
		var body := detection_data.body
		
		if not _cone_check(body) or not _line_of_sight_check(body):
			if detection_data.detected:
				print_debug("%s(%s): Stopped detecting %s" % [_debug_self.name, name, body.name])
				perceive_end.emit(body)
				detection_data.clear()
			continue
		if not detection_data.detected:
			print_debug("%s(%s): Started detecting %s" % [_debug_self.name, name, body.name])
			perceive_begin.emit(body)
			detection_data.detected = true
			
	for id in invalid_ids:
		print_debug("%s(%s): Erased invalid instance %d" % [_debug_self.name, name, id])
		_detections.erase(id)
	
	if invalid_ids:
		_check_if_no_detections()
		
func _cone_check(body: Node3D) -> bool:
	# Do the planar cone check from the eyes node forward direction to the body position
	if not eyes:
		return true
		
	var body_pos:Vector2 = Utils.grid_vector(body.global_position)
	var eyes_pos:Vector2 = Utils.grid_vector(eyes.global_position)
	var to_body_dir := body_pos.direction_to(eyes_pos)
	var forward:Vector2 = Utils.grid_vector(eyes_forward)
	
	var cos_half_angle:float = to_body_dir.dot(forward)
	
	var passes := cos_half_angle <= _cone_cos
	if passes and OS.is_stdout_verbose():
		print_debug("%s(%s): Body %s is in vision cone" % [_debug_self.name, name, body.name])
		
	return passes

func _line_of_sight_check(body: Node3D) -> bool:
	# Do the LOS check from the eyes position to every test position on the body target
	# use the group nodes if specified; otherwise use the top, middle, and bottom of the bounds
	if not eyes:
		return true
		
	_ray_cast_params.from = eyes.global_position
	
	var candidate_positions:PackedVector3Array
	if line_of_sight_target_group:
		for node in Utils.down_tree_in_group(body, line_of_sight_target_group):
			var node_3d:Node3D = node as Node3D
			if node_3d:
				candidate_positions.push_back(node_3d.global_position)
	
	# Fallback is just the node position itself
	if not candidate_positions:
		candidate_positions.push_back(body.global_position)
	
	for pos in candidate_positions:
		if _is_visible(pos):
			if OS.is_stdout_verbose():
				print_debug("%s(%s): Body %s is in LOS" % [_debug_self.name, name, body.name])
			return true	
		
	return false

func _is_visible(target_pos:Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	
	_ray_cast_params.to = target_pos
	var result := space_state.intersect_ray(_ray_cast_params)
	# If we don't hit anything along the way then it is visible
	return not result
		
func _on_body_entered(body: Node3D) -> void:
	if OS.is_stdout_verbose():
		print_debug("%s(%s): Body %s is in range" % [_debug_self.name, name, body.name])
		
	_detections[body.get_instance_id()] = DetectionData.new(body)
	_scan_timer.start()

func _on_body_exited(body: Node3D) -> void:
	if OS.is_stdout_verbose():
		print_debug("%s(%s): Body %s is out of range" % [_debug_self.name, name, body.name])
		
	var instance_id := body.get_instance_id()
	var detection_data:DetectionData = _detections.get(instance_id)
	_detections.erase(instance_id)
	_check_if_no_detections()
	
	if detection_data and detection_data.detected:
		perceive_end.emit(body)

func _check_if_no_detections() -> void:
	if not _detections:
		# Stop the timer so not ticking if there is nothing to detect
		_scan_timer.stop()
