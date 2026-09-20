extends Node3D

@export var min_spawn_seconds: float = 5.0
@export var max_spawn_seconds: float = 10.0
@export var spawn_radius: float = 100.0
@export var spawn_container: Node
@export var spawn_height: float = 1.0

var pickup_options: Array[PickupObject] = []

func _ready() -> void:
	for c in get_children():
		if c is PickupObject:
			for i in range(c.spawn_weight):
				pickup_options.append(c)
			c.hide()
			c.monitoring = false
	if not spawn_container:
		spawn_container = get_parent().get_parent()
	_set_timer()

func _set_timer() -> void:
	var seconds := randf_range(min_spawn_seconds, max_spawn_seconds)
	var timer := get_tree().create_timer(seconds)
	timer.timeout.connect(_spawn_pickup)

func _spawn_pickup() -> void:
	if get_tree().paused == false: # skip if game is paused
		var choice := randi_range(0, pickup_options.size() - 1)
		var obj := pickup_options[choice].duplicate()
		var angle := randf_range(0.0, PI * 2.0)
		var dist := randf_range(spawn_radius / 2.0, spawn_radius)
		var offset = Vector2.from_angle(angle) * dist
		spawn_container.add_child(obj)
		obj.global_position = global_position + Vector3(offset.x, 1.0, offset.y)
		
		# enforce_boundary
		var limits: Dictionary[String, float] = GameGlobal.world_boundaries.get_world_limits()
		
		if obj.global_position.x > limits["+x"]:
			obj.global_position.x = limits["+x"]
		if obj.global_position.x < limits["-x"]:
			obj.global_position.x = limits["-x"]
		if obj.global_position.z > limits["+z"]:
			obj.global_position.z = limits["+z"]
		if obj.global_position.z < limits["-z"]:
			obj.global_position.z = limits["-z"]
		
		obj.show()
		obj.monitoring = true
		GameLogger.debug("Adding " + str(choice) + " at " + str(offset))
	_set_timer()
