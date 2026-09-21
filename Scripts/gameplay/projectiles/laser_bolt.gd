class_name LaserBolt
extends Area3D

## How fast the projectile moves
@export var speed: float = 30.0
## How long before projectile is automatically destroyed (like if it travels out of bounds for example)
@export var destroy_delay: float = 5.0
@export var bounce_off_powerful_enemy: bool = false

const LASER_HIT_TSCN: PackedScene = preload("res://Scenes - Particles/laser_hit.tscn")

@onready var damage_component := $DamageComponent
var damage_amount: float
## Default to this much damage if no damage component found
const default_damage: float = 10.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(destroy_delay).timeout.connect(queue_free) # remove after 5 sec (long out of bounds)
	
	# safeguard and error message in case no damage component is found
	if damage_component == null:
		push_error(name + " is missing damage component! Please add one")
		damage_component = DamageComponent.new()
		damage_component.amount = default_damage

func _physics_process(delta: float) -> void:
	global_position += -global_basis.z * speed * delta

func _on_area_entered(area: Area3D) -> void:
	# print(area.name)
	if area.get_parent().is_in_group("enemy"):
		var enemy := area.get_parent() as Enemy
		if bounce_off_powerful_enemy == false || enemy.get_max_health() < 500:
			Utils.damage_enemy(enemy, damage_component.amount)
			# AudioStreamManager.play_sfx("res://Sound Effects/Enemy/hitsound_2.wav", AudioStreamManager.PlaybackMode.STANDARD)
			explode_and_remove()
		else: # richochet, target too powerful
			global_basis.z = -global_basis.z
			AudioStreamManager.play_sfx("res://Sound Effects/Lasers/laser_ricochet_1.wav", AudioStreamManager.PlaybackMode.RANDOM_PITCH)
			var max_deviate = deg_to_rad(30.0)
			var deviate_amount = randf_range(-max_deviate, max_deviate)
			global_basis = global_basis.rotated(Vector3.UP, deviate_amount)
			deviate_amount = randf_range(-max_deviate, max_deviate)
			global_basis = global_basis.rotated(Vector3.RIGHT, deviate_amount)

func _on_body_entered(_body: Node3D) -> void:
	# print(body.name)
	explode_and_remove()

func explode_and_remove() -> void:
	var hit_effect := LASER_HIT_TSCN.instantiate()
	get_tree().current_scene.add_child(hit_effect)
	hit_effect.global_position = global_position
	queue_free()
