extends Area3D
class_name LightningBolt

## set this while instantiating the scene!
var lightning_source: Node3D
var intended_position: Vector3

@export var lifetime_sec: float = 0.3
@export var arc_segment_count: int = 10
@export var arc_segment_vareity: int = 3
@export var arc_height_min: float = 5.
@export var arc_height_max: float = 7.
@export_range(0., 1.) var arc_scatteredness: float = 0.75
@export_range(0., 1.) var arc_volatility: float = 0.15
@export var default_enemy_capacity: float = 0.2

@onready var arc_material: ORMMaterial3D = ORMMaterial3D.new()
func add_line(pos1: Vector3, pos2: Vector3, color = Color.AQUA) -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var immediate_mesh: ImmediateMesh = ImmediateMesh.new()

	mesh_instance.top_level = true
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, arc_material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()

	arc_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arc_material.albedo_color = color

	return mesh_instance

func remake_arc() -> void:
	for seg in segments: seg.queue_free()
	segments.clear()
	for s in (arc.size() - 1):
		segments.push_back(add_line(arc[s], arc[s+1]))
		add_child(segments[-1])

## A dictionary of enemies in range and their conduction capacity == time until they release the current endpoint of the lightning bolt
var enemies_in_range: Dictionary[Node3D, float]
func _on_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("enemy"):
		enemies_in_range[area.get_parent() as Node3D] = default_enemy_capacity

func _on_area_exited(area: Area3D) -> void:
	if enemies_in_range.has(area.get_parent()): enemies_in_range.erase(area.get_parent())

@onready var arc: Array[Vector3] = [lightning_source.global_position]
@onready var segments: Array[MeshInstance3D] = []
func _ready() -> void:
	global_position = intended_position
	var arc_point_count: int = arc_segment_count + randi_range(-arc_segment_vareity, arc_segment_vareity) + 2
	var arc_range: float = (arc_height_max - arc_height_min)
	for i in arc_point_count:
		var arc_positional_ratio: float = float(i) / float(arc_point_count)
		var pos: Vector3 = ( # The segment position connects the source and base of the arc
			lerp(lightning_source.global_position, global_position, arc_positional_ratio)
			+ Vector3(0., arc_height_min - abs(0.5 - arc_positional_ratio) * arc_height_max * 0.5, 0.) # middle part of the arc is higher
			+ Vector3.ONE * (randf() - 0.5) * 2. * arc_scatteredness * arc_range # and it's also a bit random
		)
		arc.push_back(pos)
	arc.push_back(global_position)
	remake_arc()

@onready var time_left: float = lifetime_sec
func _process(delta: float) -> void:
	time_left -= delta
	if 0. >= time_left: queue_free()

	# Handle damaging enemies
	if not enemies_in_range.is_empty():
		var victim: Node3D = enemies_in_range.keys().pick_random()
		if 0. < enemies_in_range[victim]:
			enemies_in_range[victim] -= delta
			arc[-randi_range(0, min(arc.size(), 3))] = victim.global_position
		else:
			if victim.has_method("die"): victim.die()
			else: victim.queue_free()

	# move lightning bolt around
	for p in arc.size():
		if p == 0 or p == arc.size() - 1: continue
		arc[p] = lerp(
			arc[p], arc[p] + Vector3.ONE * (randf() - 0.5) * 2. * arc_scatteredness * (arc_height_max - arc_height_min),
			arc_volatility
		)
		arc[p].y = max(arc_height_min, arc[p].y)
	remake_arc()
