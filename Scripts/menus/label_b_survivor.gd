extends Label

func _ready() -> void:
	var base_text = text
	if GameGlobal.won_surv:
		text = "COMPLETED: " + base_text
	else:
		text = "CHAPTER 2: " + base_text
