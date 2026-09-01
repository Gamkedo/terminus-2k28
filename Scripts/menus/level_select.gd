extends Node

@export var starting_focus: Control

func _ready() -> void:
	starting_focus.grab_focus()
	AudioStreamManager.play_bgm("res://Music/terminus1_vorbis.ogg")

func _on_area_a_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes - Levels/areaArcade.tscn")

func _on_area_b_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes - Levels/areaSurvivor.tscn")

func _on_area_c_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes - Levels/areaImmersive.tscn")
