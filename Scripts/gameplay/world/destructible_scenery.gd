## Scenery that can be destroyed
extends Enemy

## Particles to spawn when destroyed
@export var destroy_particles: Array[PackedScene]

@export var dest_anim_name: String = "destroy_anim"

@onready var collider = $Area3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func die() -> void:
	if destroy_particles:
		for part in destroy_particles:
			var dest_parts = part.instantiate()
			get_tree().current_scene.add_child(dest_parts)
			dest_parts.global_position = global_position
	collider.queue_free()
	anim_player.play(dest_anim_name)
