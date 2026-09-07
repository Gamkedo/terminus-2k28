extends Node3D

@onready var child_particle: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	child_particle.finished.connect(queue_free)
	child_particle.restart() # wake up emitter
