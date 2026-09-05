## Steady laser beam
extends Node3D

## Raycast used to check hits cuz godot doesn't like scaling colliders
@onready var beam_ray := $BeamRay as RayCast3D
## Endpoint of the beam sprite, used to calculate stretch distance
@onready var beam_end := $BeamEnd

## Initial length beam will stretch with no target (rare)
@export var max_dist: float = 50.0
## How frequently to damage tick, update length, and spawn particles
@export var scale_update_interval = 0.1

## Length of beam sprite, used to divide to find accurate beam stretch length
var beam_len: float
## Timer to count tick interval
var scale_update_timer: float = 0.0

const LASER_HIT_TSCN := preload("res://Scenes - Objects/laser_hit.tscn")

func _ready() -> void:
	beam_len = beam_end.position.z

func _physics_process(delta: float) -> void:
	scale_update_timer += delta
	
	if scale_update_timer > scale_update_interval:
		scale_update_timer = 0.0
		var beam_length = max_dist
		
		var coll_obj = beam_ray.get_collider()
		if coll_obj != null:
			# damage tick to enemies
			if coll_obj.get_parent().is_in_group("enemy"):
				var enemy := coll_obj.get_parent() as Node3D
				Utils.damage_enemy(enemy)
			
			# spawn particles
			var hit_effect := LASER_HIT_TSCN.instantiate()
			get_tree().current_scene.add_child(hit_effect)
			hit_effect.global_position = beam_end.global_position
			
			# update beam length based on raycast hit
			beam_length = (beam_ray.get_collision_point() - global_position).length() / beam_len
		scale.z = abs(beam_length)
