extends WeaponsManager
class_name StackingWeaponsManager

var active_weapons: Array[int] = []

func _ready() -> void:
	super._ready()
	if weapons.size() > 0:
		active_weapons.append(0)
		

func can_fire() -> bool:
	for w in active_weapons:
		if weapons[w].can_fire():
			return true
	return false

func fire(pos, rot) -> void:
	for w in active_weapons:
		fire_power_level(w,pos, rot)

func cycle_weapon() -> void:
	# debug hack to quickly add weapons
	var next_weapon = active_weapons.size()
	if next_weapon < weapons.size():
		active_weapons.append(next_weapon)
		weapon_activated.emit.call_deferred(next_weapon)
	GameLogger.debug("cycle stacking weapons: " + str(active_weapons))

func previous_weapon() -> void:
	if active_weapons.size() > 0:
		var n: int = active_weapons.pop_back()
		weapon_deactivated.emit.call_deferred(n)
	GameLogger.debug("previous weapon: " + str(active_weapons))

func select_weapon_num(num:int) -> void: # triggered by keyboard keys 0..9
	var idx := active_weapons.find(num)
	if idx >= 0:
		active_weapons.pop_at(idx)
		weapon_deactivated.emit.call_deferred(num)
		GameLogger.debug("removing weapon %d" % num)
	elif num < weapons.size():
		active_weapons.append(num)
		weapon_activated.emit.call_deferred(num)
		GameLogger.debug("adding weapon %d" % num)

func add_weapon(num:int) -> bool: # triggered by pickups
	if num < weapons.size():
		if num not in active_weapons:
			active_weapons.append(num)
			weapon_activated.emit.call_deferred(num)
			GameLogger.debug("adding weapon %d" % num)
		else:
			weapons[num].power_level += 1
			weapon_activated.emit.call_deferred(num)
	return true # always remove icon
	# return false
