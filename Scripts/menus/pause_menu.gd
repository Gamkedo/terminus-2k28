extends Control

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_or_unpause()
		
		
func pause_or_unpause():
	if get_tree().paused == true:
		$".".hide()
		get_tree().paused = false
		
	elif get_tree().paused == false:
		$".".show()
		get_tree().paused = true
