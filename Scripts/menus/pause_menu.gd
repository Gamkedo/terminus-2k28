extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_or_unpause()
		
		
func pause_or_unpause():
	if get_tree().paused == true:
		$".".hide()
		get_tree().paused = false
		
	elif get_tree().paused == false:
		$".".show()
		get_tree().paused = true


func _on_level_select_button_pressed():
	get_tree().change_scene_to_file("res://level_menu.tscn")
