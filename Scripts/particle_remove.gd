extends Node3D

@onready var child_particle = $GPUParticles3D

func _ready():
	child_particle.finished.connect(queue_free)
	child_particle.restart() # wake up emitter
