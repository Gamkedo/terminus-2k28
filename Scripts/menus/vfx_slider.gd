extends HSlider


# Called when the node enters the scene tree for the first time.
func _ready():
	value = ScreenVFX.get_vfx_intensity()


func _on_value_changed(val: float):
	ScreenVFX.set_vfx_intensity(val)
