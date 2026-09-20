extends Control

@onready var finalScoreLabel: Label = %FinalScoreLabel

const GAME_OVER_SOUND := preload("res://Sound Effects/UI/GameOver.wav")

func _ready() -> void:
	GameGlobal.final_score.connect(set_final_score)


func set_final_score(score: int):
	get_child(0).visible = true
	get_tree().paused = true
	AudioStreamManager.play_game_over(GAME_OVER_SOUND)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	finalScoreLabel.text = "SCORE: " + str(score).pad_zeros(6)

func _on_restart_pressed():
	get_tree().paused = false
	AudioStreamManager.restore_bgm_volume()
	get_tree().reload_current_scene()

func _on_back_to_menu_pressed():
	get_tree().paused = false
	AudioStreamManager.restore_bgm_volume()
	get_tree().change_scene_to_file("res://level_menu.tscn")
