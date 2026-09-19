extends Area3D
class_name LightningBolt

## set this while instantiating the scene!
@export var lightning_source: Node3D
@export var intended_position: Vector3

@export var lifetime_sec: float = 0.3
@export var arc_segment_count: int = 1
@export var arc_segment_vareity: int = 0
@export var arc_height_min: float = 5.
@export var arc_height_max: float = 7.
@export_range(0., 1.) var arc_scatteredness: float = 0.75
@export_range(0., 1.) var arc_volatility: float = 0.15
@export var arc_source_radius: float = 1.75
@export var default_enemy_capacity: float = 0.2

@onready var damage_component := $DamageComponent

#region Mesh Pool
static var pregenerated_meshes_count: int = 25
static var available_meshes_too_low_count: int = 5
static var available_meshes: Array[MeshInstance3D]
static var pregenerate_count: int = 0 # Debug
static func pregenerate_meshes(count: int = pregenerated_meshes_count) -> void:
	pregenerate_count += 1
	for i in count:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = ImmediateMesh.new()
		mesh_instance.top_level = true
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		available_meshes.push_back(mesh_instance)

static func request_mesh() -> MeshInstance3D:
	if available_meshes.size() < available_meshes_too_low_count: pregenerate_meshes(1)
	var mesh: MeshInstance3D = available_meshes.pop_back()
	mesh.mesh.clear_surfaces()
	return mesh

static func return_mesh(mesh: MeshInstance3D) -> void:
	mesh.get_parent().remove_child(mesh) # Remove mesh from scene tree without freeing it
	available_meshes.push_back(mesh)
#endregion

@onready var arc_material: ORMMaterial3D = ORMMaterial3D.new()
var arc: MeshInstance3D
func remake_arc(color = Color.AQUA) -> void:
	if arc: return_mesh(arc) # always request a new mesh to re-initialize it
	arc = request_mesh()
	arc_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arc_material.albedo_color = color

	arc.mesh.surface_begin(Mesh.PRIMITIVE_LINES, arc_material)
	for s in (arc_points.size() - 1):
		arc.mesh.surface_add_vertex(arc_points[s])
		arc.mesh.surface_add_vertex(arc_points[s+1])
	arc.mesh.surface_end()
	add_child(arc)

func refresh_arc(color = Color.AQUA) -> void:
	var randomized_color: Color = color.lightened(randf())
	arc_material.albedo_color = Color.from_hsv(randomized_color.h + randf_range(-0.05, 0.05), randomized_color.s, randomized_color.v)
	arc.mesh.clear_surfaces()
	arc.mesh.surface_begin(Mesh.PRIMITIVE_LINES, arc_material)
	for s in (arc_points.size() - 1):
		arc.mesh.surface_add_vertex(arc_points[s])
		arc.mesh.surface_add_vertex(arc_points[s+1])
	arc.mesh.surface_end()

## A dictionary of enemies in range and their conduction capacity == time until they release the current endpoint of the lightning bolt
var enemies_in_range: Dictionary[Node3D, float]
func _on_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("enemy"):
		enemies_in_range[area.get_parent() as Node3D] = default_enemy_capacity

func _on_area_exited(area: Area3D) -> void:
	if enemies_in_range.has(area.get_parent()): enemies_in_range.erase(area.get_parent())

func bolt_start_position() -> Vector3:
	return (
		lightning_source.global_position
		+ (global_position - lightning_source.global_position).normalized() * arc_source_radius
		+ Vector3(0., 2., 0.)
	)

@onready var arc_points: Array[Vector3] = [lightning_source.global_position]
func _ready() -> void:
	global_position = intended_position
	var arc_point_count: int = arc_segment_count + randi_range(-arc_segment_vareity, arc_segment_vareity) + 2
	var arc_range: float = (arc_height_max - arc_height_min)
	arc_points.resize(arc_point_count + 1)
	arc_points[0] = bolt_start_position()
	for i in arc_point_count:
		if 0 == i: continue
		var arc_positional_ratio: float = float(i) / float(arc_point_count)
		var pos: Vector3 = ( # The segment position connects the source and base of the arc
			lerp(lightning_source.global_position, global_position, arc_positional_ratio)
			+ Vector3(0., arc_height_min - abs(0.5 - arc_positional_ratio) * arc_height_max * 0.5, 0.) # middle part of the arc is higher
			+ Vector3.ONE * (randf() - 0.5) * 2. * arc_scatteredness * arc_range # and it's also a bit random
		)
		arc_points[i] = pos
	arc_points[arc_point_count] = global_position
	remake_arc()

@onready var time_left: float = lifetime_sec
func _process(delta: float) -> void:
	time_left -= delta
	if 0. >= time_left:
		return_mesh(arc)
		queue_free()

	# Handle light fake
	$LightFake.scale = Vector3.ONE * clamp($LightFake.scale.x * randf(), 5., 15.) * time_left / lifetime_sec

	# Handle damaging enemies
	if not enemies_in_range.is_empty():
		var victim: Enemy = enemies_in_range.keys().pick_random()
		if 0. < enemies_in_range[victim]:
			enemies_in_range[victim] -= delta
			arc_points[-randi_range(1, min(arc_points.size(), 4))] = victim.global_position
		else:
			Utils.damage_enemy(victim, damage_component.amount)
			victim.stun_time = 5.0 # currently only affects smart droids

	# move lightning bolt around
	arc_points[0] = bolt_start_position()
	for p in arc_points.size():
		if p == 0 or p == arc_points.size() - 1: continue
		arc_points[p] = lerp(
			arc_points[p], arc_points[p] + Vector3.ONE * (randf() - 0.5) * 2. * arc_scatteredness * (arc_height_max - arc_height_min),
			arc_volatility
		)
		arc_points[p].y = max(arc_height_min, arc_points[p].y)
	refresh_arc()
