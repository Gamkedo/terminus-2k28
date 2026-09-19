class_name PickupObject
extends Area3D

@export var effect: PickupEffect

## this only matters if this pickup is managed by a PickupSpawner
## 1.0 means it has an equal chance of appearing to other 1.0 weights
## 0.5 means less likely to appear. 2.0 means more likely
## (think flexbox in css)
@export var spawn_weight: float = 1.0

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if effect and effect.apply(body):
		queue_free()
