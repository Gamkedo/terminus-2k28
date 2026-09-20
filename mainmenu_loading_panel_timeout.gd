extends Panel

func _ready() -> void: # hides controls during load freeze after missions
	get_tree().create_timer(0.1).timeout.connect(queue_free)
