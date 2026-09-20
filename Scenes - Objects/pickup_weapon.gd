extends PickupObject
class_name WeaponPickupObject

@onready var sprite_3d: Sprite3D = $Sprite3D

const LIFETIME_MAX := 25.0
const FLICKER_TIME := 6.5 # flashes for this amount of time left
const MAX_START_BIGGER_SCALE_PERC := 0.65
const SHRINK_IN_TIME := 0.75 # scales down to normal size over this interval
var lifetime := LIFETIME_MAX
var graphic_height = 1 # calculate in _ready
const SHRINK_ABOVE_TIME := LIFETIME_MAX-SHRINK_IN_TIME

func _ready() -> void:
	var typed_effect: WeaponPickupEffect
	if effect and effect is WeaponPickupEffect:
		typed_effect = effect
		sprite_3d.frame = typed_effect.weapon_number
		sprite_3d.visible = true
		graphic_height = sprite_3d.pixel_size*sprite_3d.texture.get_height()/10

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime > SHRINK_ABOVE_TIME:
		var shrink_amount = lifetime - SHRINK_ABOVE_TIME
		var shrink_perc = shrink_amount / SHRINK_IN_TIME
		var change_amount = shrink_perc*MAX_START_BIGGER_SCALE_PERC
		sprite_3d.scale = Vector3.ONE * (1.0+change_amount)
		sprite_3d.global_position.y = 1.0+change_amount*graphic_height
	elif sprite_3d.scale.x != 1.0:
		sprite_3d.scale = Vector3.ONE
		sprite_3d.global_position.y = 1.0
	
	if lifetime < FLICKER_TIME:
		var time_left_perc := lifetime / FLICKER_TIME
		var flash_math = int(time_left_perc*30)
		sprite_3d.visible = flash_math % 2 == 1
