extends Node3D

# note: if there are other children (sounds, animations,
# other particles) make sure CPUParticles3D's time is set
# so it finishes last, or it'll abruptly cut off siblings
@onready var child_particle: CPUParticles3D = $CPUParticles3D

func _ready() -> void:
	child_particle.finished.connect(queue_free)
	child_particle.restart() # wake up emitter
