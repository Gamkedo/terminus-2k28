extends PickupObject
class_name WeaponPickupObject

@onready var sprite_3d: Sprite3D = $Sprite3D

func _ready() -> void:
	var typed_effect: WeaponPickupEffect
	if effect and effect is WeaponPickupEffect:
		typed_effect = effect
		sprite_3d.frame = typed_effect.weapon_number
