# enemy that spawns other enemies

extends Enemy

# Which enemy to spawn
@export var spawn_enemy: PackedScene = null
# How frequently do we spawn enemies (in seconds) (if below max_spawn_count)
@export var spawn_interval := 2.5
# Spawns this many, then stops until some are destroyed
@export var max_spawn_count := 5
# force start flipped
@export var start_flipped := false
# randomly flip sprite left/right at the start
@export var rand_start_dir := false
# true to randomize percent completion of spawn_interval on start
@export var rand_start_progress := true
# how often to check and remove destroyed enemies from spawned_enemies
@export var reactivate_check_interval := 1.5
# how dramatically to deform while churning out enemy - squish=height,stretch=width
@export var enable_deform = true
@export var squish_min = 0.8
@export var squish_max = 1.2
@export var stretch_min = 0.9
@export var stretch_max = 1.4
# particles to emit when spawning an enemy
@export var spawn_particles: PackedScene = null
@export var particle_spawn_spot: Node3D = null

# sprite for when we're able to spawn enemies
@onready var graphic_active = $BillboardActive
# reached max enemies, no more spawning until some are destroyed
@onready var graphic_inactive = $BillboardInactive
# we may be destroyed, but our sprite will remain
@onready var graphic_destroyed = $BillboardDestroyed

var spawn_timer := 0.0
var reactivate_timer := 0.0
var spawned_enemies := []
var active := true
var destroyed := false

func _ready() -> void:
	# flip sprites based on export parameters
	var flip = (start_flipped or (rand_start_dir and randf() < 0.5))
	graphic_active.flip_h = flip
	graphic_inactive.flip_h = flip
	graphic_destroyed.flip_h = flip
	
	if rand_start_progress: spawn_timer = randf() * spawn_interval

func _process(delta: float) -> void:
	if destroyed: return # just in case
	# spawn enemies if count is less than max_spawn_count
	if active:
		spawn_timer += delta
		
		# deform for spawn enemy animation
		if enable_deform:
			var timer_percent = min(spawn_timer / spawn_interval,1.0) * PI + (PI /  2.0)
			graphic_active.scale.x = (abs(sin(timer_percent)) * (stretch_max - stretch_min) + stretch_min)
			graphic_active.scale.y = (abs(cos(timer_percent)) * (squish_max - squish_min) + squish_min)
		
		# spawn enemy if timer is done
		if spawn_timer >= spawn_interval:
			spawn_timer = 0.0
			var spawned_enemy := spawn_enemy.instantiate()
			get_tree().current_scene.add_child(spawned_enemy)
			spawned_enemy.global_position = position
			spawned_enemies.push_back(spawned_enemy)
			if spawned_enemies.size() >= max_spawn_count:
				toggle_active(false)
			var parts = spawn_particles.instantiate()
			get_tree().current_scene.add_child(parts)
			var part_spawn_pos = position
			if particle_spawn_spot: part_spawn_pos = particle_spawn_spot.global_position
			parts.global_position = part_spawn_pos
	elif spawn_enemy: # check if spawned enemies are below max_spawn_count, in which case reactivate
		reactivate_timer += delta
		if reactivate_timer >= reactivate_check_interval:
			reactivate_timer = 0.0
			var n_cur_enemies := 0
			# loop backwards to avoid problems by removing elements mid-loop
			for i in range(spawned_enemies.size() - 1,-1,-1):
				if spawned_enemies[i]:
					n_cur_enemies += 1
				else:
					spawned_enemies.remove_at(i)
			if n_cur_enemies < max_spawn_count:
				toggle_active(true)

# toggle spawning
func toggle_active(is_active: bool) -> void:
	active = is_active
	graphic_active.visible = is_active
	graphic_inactive.visible = !is_active
	if not is_active: graphic_inactive.scale = graphic_active.scale

func die() -> void:
	super.die()
	destroyed = true
	toggle_active(false)
	graphic_inactive.visible = false
	graphic_destroyed.scale = graphic_active.scale
	graphic_destroyed.reparent(get_tree().current_scene)
	graphic_destroyed.visible = true
