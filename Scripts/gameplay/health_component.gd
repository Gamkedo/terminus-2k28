extends Node
class_name HealthComponent

signal health_depleted

@export var max_health := 100

@onready var curr_health = max_health : set = set_curr_health

func take_damage(amount: int) -> void:
	GameLogger.debug("%s took %d damage" % [get_parent().name, amount])
	curr_health -= amount

func heal(amount: int) -> void:
	curr_health += amount

func set_curr_health(value):
	curr_health = clamp(value, 0, max_health)
	if curr_health == 0:
		health_depleted.emit()
		die()

func die() -> void:
	var p = get_parent()
	if p.has_method("die"):
		p.die()
	else:
		p.queue_free()
