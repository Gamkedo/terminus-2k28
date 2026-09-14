extends Node3D

@onready var child_particle: CPUParticles3D = $CPUParticles3D

func _ready() -> void:
	child_particle.finished.connect(queue_free)
	child_particle.restart() # wake up emitter
