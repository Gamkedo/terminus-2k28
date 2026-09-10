extends Node3D

@onready var child_sprite: AnimatedSprite3D = $BillboardFront

func _ready() -> void:
	# couldn't find where in inspector to turn off loop, forcing off in code
	child_sprite.sprite_frames.set_animation_loop(child_sprite.animation, false)
	child_sprite.animation_finished.connect(queue_free)
	child_sprite.play()
