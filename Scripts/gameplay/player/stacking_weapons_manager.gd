extends WeaponsManager
class_name StackingWeaponsManager

var active_weapons: Array[int] = []

func can_fire() -> bool:
	return true

func fire(pos, rot) -> void:
	for w in active_weapons:
		if weapons[w].can_fire():
			weapons[w].fire(pos, rot)

func cycle_weapon() -> void:
	# debug hack to quickly add weapons
	var next_weapon = active_weapons.size()
	if next_weapon < weapons.size():
		active_weapons.append(next_weapon)
