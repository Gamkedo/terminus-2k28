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
		if weapons[w].can_fire():
			match w: # hey godot can use a switch case, neat!
				0,1: # single laser or spread
					var power_rot: float = rot.y
					var angle_step: float = TAU / float(weapons[w].power_level)
					for i in range(weapons[w].power_level):
						weapons[w].fire(pos, Vector3(rot.x, power_rot, rot.z))
						power_rot += angle_step
				2: # beam
						weapons[w].fire(pos, rot)
						weapons[w].reload_time *= 1.0 / float(weapons[w].power_level)
						# keep beam dur less than reload time to avoid lingering beams
						weapons[w].beam_dur = weapons[w].reload_time * 0.9
				3: # lightning
						weapons[w].fire(pos, rot)
						# power 2 has half reload time, power 3 has third etc
						weapons[w].reload_time *= 1.0 / float(weapons[w].power_level)
				# note: the above should be defined const/enum BUT:
				# the ordering is not guaranteed, it's based on arrangement in the
				# player.tscn, and, importantly, this game ships tomorrow ;)
				# (so it's both unlikely to change and not worth a bigger refactor
				# to ensure they keep a given order)

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
			print("to do (WIP): increment power counter on this weapon, power level: ")
			print(weapons[num].power_level)
	return true # always remove icon
	# return false
