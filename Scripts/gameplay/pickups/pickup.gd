extends Area3D

@export var effect: PickupEffect

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if effect and effect.apply(body):
		queue_free()
