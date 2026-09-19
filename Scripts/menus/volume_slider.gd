extends HSlider


# Called when the node enters the scene tree for the first time.
func _ready():
	value = AudioStreamManager._global_volume


func _on_value_changed(value):
	AudioStreamManager.set_global_volume(value)
