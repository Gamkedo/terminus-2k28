extends Node

@export var area_a: Button

func _ready() -> void:
	area_a.grab_focus()

func _on_area_a_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes - Levels/areaA.tscn")

func _on_area_b_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes - Levels/areaB.tscn")

func _on_area_c_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes - Levels/areaC.tscn")
