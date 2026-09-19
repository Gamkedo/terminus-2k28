extends VBoxContainer

@export var show_all := false

@onready var template: Control = $WeaponIconTemplate

var visible_icons: Array[Control] = []
var visible_nums: Array[int] = []
var weapons_manager: WeaponsManager

func _ready() -> void:
	template.hide()
	var p: Player = GameGlobal.player_ref
	weapons_manager = p.weapons_manager
	weapons_manager.weapon_activated.connect(_on_weapon_activated)
	weapons_manager.weapon_deactivated.connect(_on_weapon_deactivated)
	if show_all:
		for i in range(weapons_manager.weapons.size()):
			_add_icon(i, weapons_manager.weapons[i].label_text)
			_dim_icon(i)
	_on_weapon_activated.call_deferred(0)


func _dim_icon(num: int) -> void:
	if num < visible_icons.size():
		visible_icons[num].modulate = Color.DIM_GRAY

func _undim_icon(num: int) -> void:
	if num < visible_icons.size():
		visible_icons[num].modulate = Color.WHITE

func _add_icon(num: int, label_text: String) -> Control:
	var control: Control = template.duplicate()
	var icon: Sprite2D = control.get_child(0)
	icon.frame = num
	var label: Label = control.get_child(1)
	label.text = label_text
	add_child(control)
	control.show()
	visible_icons.append(control)
	return control

func _on_weapon_activated(num: int) -> void:
	if num not in visible_nums:
		if show_all:
			_undim_icon(num)
		else:
			_add_icon(num, weapons_manager.weapons[num].label_text)
		visible_nums.append(num)

func _on_weapon_deactivated(num: int) -> void:
	if num in visible_nums:
		var idx = visible_nums.find(num)
		visible_nums.pop_at(idx)
		if show_all:
			_dim_icon(num)
		else:
			var control: Control = visible_icons.pop_at(idx)
			control.queue_free()
