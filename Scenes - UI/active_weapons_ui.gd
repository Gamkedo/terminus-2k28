extends VBoxContainer

@onready var template: Control = $WeaponIconTemplate

var visible_icons: Array[Control] = []
var visible_nums: Array[int] = []

func _ready() -> void:
	template.hide()
	var p: Player = GameGlobal.player_ref
	p.weapons_manager.weapon_activated.connect(_on_weapon_activated)
	p.weapons_manager.weapon_deactivated.connect(_on_weapon_deactivated)
	_on_weapon_activated.call_deferred(0)

func _on_weapon_activated(num: int) -> void:
	if num not in visible_nums:
		var control: Control = template.duplicate()
		var icon: Sprite2D = control.get_child(0)
		icon.frame = num
		add_child(control)
		control.show()
		visible_nums.append(num)
		visible_icons.append(control)

func _on_weapon_deactivated(num: int) -> void:
	if num in visible_nums:
		var idx = visible_nums.find(num)
		visible_nums.pop_at(idx)
		var control: Control = visible_icons.pop_at(idx)
		control.queue_free()
