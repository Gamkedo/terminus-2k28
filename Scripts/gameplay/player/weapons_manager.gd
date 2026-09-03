extends Node
class_name WeaponsManager

var weapons: Array[Weapon] = []
var active_weapon := 0

func _ready() -> void:
	var player := get_parent() as Player
	if player:
		player.weapons_manager = self
	for child in get_parent().get_children():
		if child is Weapon: weapons.append(child)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_cycle_weapon"):
		# Quick test for swapping weapons
		cycle_weapon()

func can_fire() -> bool:
	return weapons[active_weapon].can_fire()

func fire(pos, rot) -> void:
	weapons[active_weapon].fire(pos, rot)

func cycle_weapon() -> void:
	active_weapon += 1
	if active_weapon >= weapons.size():
		active_weapon = 0
