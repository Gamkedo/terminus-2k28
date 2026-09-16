## Scenery that can be destroyed
extends Enemy

## Particles to spawn when destroyed
@export var destroy_particles: Array[PackedScene]

@export var anim_player: AnimationPlayer = null
@export var dest_anim_name: String = "destroy_anim"

@export var destroy_self: bool = false

@export var part_spawn_spot: Node3D = null

@onready var collider = $Area3D

func die() -> void:
	if destroy_particles:
		for part in destroy_particles:
			var dest_parts = part.instantiate()
			get_tree().current_scene.add_child(dest_parts)
			if part_spawn_spot: dest_parts.global_position = part_spawn_spot.global_position
			else: dest_parts.global_position = global_position
	
	if anim_player: anim_player.play(dest_anim_name)
	
	if destroy_self: queue_free()
	else: collider.queue_free()
