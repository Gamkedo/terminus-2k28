extends Node


const loading_screen_uid: String = "uid://ce54pu4cqm5ud"
var previous_scene_path: String = "uid://c7hc705w0hq2y" # default to level menu


func change_scene(scene_path) -> void:
	var loading_screen = load(loading_screen_uid).instantiate() as LoadingScreen
	loading_screen.scene_path = scene_path
	get_tree().change_scene_to_node(loading_screen)

func return_to_menu(scene_path) -> void:
	var menu_screen = load(previous_scene_path)
	get_tree().paused = false
	get_tree().change_scene_to_packed.call_deferred(menu_screen)
