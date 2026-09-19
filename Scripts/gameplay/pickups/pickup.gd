class_name PickupObject
extends Area3D

@export var effect: PickupEffect

## this only matters if this pickup is managed by a PickupSpawner
## 1 means it has an equal chance of appearing to other 1 weights
## 2 means twice as likely.
@export var spawn_weight: int = 1

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if effect and effect.apply(body):
		queue_free()
