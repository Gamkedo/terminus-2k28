extends Control

var prev_mouse_mode: Input.MouseMode
@onready var unpause_button: Button = %UnpauseButton

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_or_unpause()
		
		
func pause_or_unpause():
	if get_tree().paused == true:
		$".".hide()
		Input.mouse_mode = prev_mouse_mode
		get_tree().paused = false
		
	elif get_tree().paused == false:
		prev_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
		$".".show()
		get_tree().paused = true
		AudioStreamManager.lightning_loop_abrupt_stop()
		unpause_button.grab_focus()


func _on_level_select_button_pressed():
	SceneChanger.return_to_menu()
