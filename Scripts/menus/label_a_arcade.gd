extends Label

func _ready() -> void:
	var base_text = text
	if GameGlobal.won_arc:
		text = "COMPLETED: " + base_text
	else:
		text = "CHAPTER 1: " + base_text
