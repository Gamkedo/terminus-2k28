extends Area3D

const SPEED = 30.0

const LASER_HIT_TSCN = preload("res://Scenes - Objects/laser_hit.tscn")

func _ready():
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(5.0).timeout.connect(queue_free) # remove after 5 sec (long out of bounds)

func _physics_process(delta):
	global_position += -global_basis.z * SPEED * delta

func _on_body_entered(body):
	var hit_effect = LASER_HIT_TSCN.instantiate()
	get_tree().current_scene.add_child(hit_effect)
	hit_effect.global_position = global_position
	queue_free()
