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
	if Input.is_action_just_pressed("debug_cycle_weapon"): # currently "Q"
		cycle_weapon()
	if Input.is_action_just_pressed("debug_previous_weapon"): # currently "E"
		previous_weapon()
	# keyboard number keys to switch weapons
	if Input.is_action_just_pressed("weapon1"): select_weapon_num(0)
	if Input.is_action_just_pressed("weapon2"): select_weapon_num(1)
	if Input.is_action_just_pressed("weapon3"): select_weapon_num(2)
	if Input.is_action_just_pressed("weapon4"): select_weapon_num(3)
	if Input.is_action_just_pressed("weapon5"): select_weapon_num(4)
	if Input.is_action_just_pressed("weapon6"): select_weapon_num(5)
	if Input.is_action_just_pressed("weapon7"): select_weapon_num(6)
	if Input.is_action_just_pressed("weapon8"): select_weapon_num(7)
	if Input.is_action_just_pressed("weapon9"): select_weapon_num(8)
	if Input.is_action_just_pressed("weapon0"): select_weapon_num(9)

func can_fire() -> bool:
	return weapons[active_weapon].can_fire()

func fire(pos, rot) -> void:
	weapons[active_weapon].fire(pos, rot)

func cycle_weapon() -> void:
	active_weapon += 1
	if active_weapon >= weapons.size():
		active_weapon = 0

func previous_weapon() -> void:
	active_weapon -= 1
	if active_weapon < 0:
		active_weapon = weapons.size()-1

func select_weapon_num(num:int) -> void: # triggered by keyboard keys 0..9
	active_weapon = num
	# we may have fewer than ten weapons:
	if active_weapon < 0: active_weapon = weapons.size()-1
	if active_weapon >= weapons.size(): active_weapon = 0
