extends Label

func _ready() -> void:
	var base_text = text
	if GameGlobal.won_imm:
		text = "COMPLETED: " + base_text
	else:
		text = "CHAPTER 3: " + base_text
