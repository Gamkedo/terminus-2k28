extends Label

func _ready() -> void:
	visible = GameGlobal.won_arc && GameGlobal.won_surv && GameGlobal.won_imm
