extends Node

@onready var area_a: Button = $AreaA

func _ready() -> void:
	area_a.grab_focus()

func _on_area_a_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes - Levels/areaA.tscn")
