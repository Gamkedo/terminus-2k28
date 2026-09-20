extends Node
class_name WeaponsManager

signal weapon_activated(n: int)
signal weapon_deactivated(n: int)

@export var allow_keyboard_switching := true

var weapons: Array[Weapon] = []
var active_weapon := 0

func _ready() -> void:
	var player := get_parent() as Player
	if player:
		player.weapons_manager = self
	for child in get_parent().get_children():
		if child is Weapon: 
			weapons.append(child)

func _input(event: InputEvent) -> void:
	if not allow_keyboard_switching:
		return
	if event.is_action_pressed("debug_cycle_weapon"): # currently "Q"
		cycle_weapon()
	if event.is_action_pressed("debug_previous_weapon"): # currently "E"
		previous_weapon()
	# keyboard number keys to switch weapons
	if event.is_action_pressed("weapon1"): select_weapon_num(0)
	if event.is_action_pressed("weapon2"): select_weapon_num(1)
	if event.is_action_pressed("weapon3"): select_weapon_num(2)
	if event.is_action_pressed("weapon4"): select_weapon_num(3)
	if event.is_action_pressed("weapon5"): select_weapon_num(4)
	if event.is_action_pressed("weapon6"): select_weapon_num(5)
	if event.is_action_pressed("weapon7"): select_weapon_num(6)
	if event.is_action_pressed("weapon8"): select_weapon_num(7)
	if event.is_action_pressed("weapon9"): select_weapon_num(8)
	if event.is_action_pressed("weapon0"): select_weapon_num(9)

func can_fire() -> bool:
	return weapons[active_weapon].can_fire()

func fire_power_level(wep, pos, rot) -> void:
	if weapons[wep].can_fire():
		match wep: # hey godot can use a switch case, neat!
			0,1: # single laser or spread
				var power_rot: float = rot.y
				var angle_step: float = TAU / float(weapons[wep].power_level)
				for i in range(weapons[wep].power_level):
					weapons[wep].fire(pos, Vector3(rot.x, power_rot, rot.z))
					power_rot += angle_step
			2: # beam
					weapons[wep].fire(pos, rot)
					weapons[wep].reload_time *= 1.0 / float(weapons[wep].power_level)
					# keep beam dur less than reload time to avoid lingering beams
					weapons[wep].beam_dur = weapons[wep].reload_time * 0.9
			3: # lightning
					weapons[wep].fire(pos, rot)
					# power 2 has half reload time, power 3 has third etc
					weapons[wep].reload_time *= 1.0 / float(weapons[wep].power_level)
			# note: the above should be defined const/enum BUT:
			# the ordering is not guaranteed, it's based on arrangement in the
			# player.tscn, and, importantly, this game ships tomorrow ;)
			# (so it's both unlikely to change and not worth a bigger refactor
			# to ensure they keep a given order)

func fire(pos, rot) -> void:
	fire_power_level(active_weapon,pos, rot)

func cycle_weapon() -> void:
	weapon_deactivated.emit.call_deferred(active_weapon)
	active_weapon += 1
	if active_weapon >= weapons.size():
		active_weapon = 0
	weapon_activated.emit.call_deferred(active_weapon)
	GameLogger.debug("cycle weapon: %d" % active_weapon)

func previous_weapon() -> void:
	weapon_deactivated.emit.call_deferred(active_weapon)
	active_weapon -= 1
	if active_weapon < 0:
		active_weapon = weapons.size()-1
	weapon_activated.emit.call_deferred(active_weapon)
	GameLogger.debug("previous weapon: %d" % active_weapon)

func select_weapon_num(num:int) -> void: # triggered by keyboard keys 0..9
	weapon_deactivated.emit.call_deferred(active_weapon)
	active_weapon = num
	# we may have fewer than ten weapons:
	if active_weapon < 0: active_weapon = weapons.size()-1
	if active_weapon >= weapons.size(): active_weapon = 0
	weapon_activated.emit.call_deferred(active_weapon)
	GameLogger.debug("select weapon: %d" % active_weapon)

# this is slightly different for the stacking implentation
# and it's what is called by pickups
func add_weapon(num:int) -> bool:
	if active_weapon == num:
		weapons[num].power_level += 1
	select_weapon_num(num)
	return true
