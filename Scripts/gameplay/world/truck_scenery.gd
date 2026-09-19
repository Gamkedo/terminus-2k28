extends DestructScenery


func die() -> void:
	super.die()
	AudioStreamManager.play_sfx("res://Sound Effects/Explosions/explosion_5.wav", AudioStreamManager.PlaybackMode.RANDOM_PITCH)
	remove_from_group("enemy")
