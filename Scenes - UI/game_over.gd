extends Control

@onready var finalScoreLabel: Label = %FinalScoreLabel

func _ready() -> void:
	GameGlobal.final_score.connect(set_final_score)

func set_final_score(score: int):
	get_child(0).visible = true
	get_tree().paused = true
	finalScoreLabel.text = "SCORE: " + str(score).pad_zeros(6)

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_back_to_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level_menu.tscn")
