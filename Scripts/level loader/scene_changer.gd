extends Node


const loading_screen_uid: String = "uid://ce54pu4cqm5ud"
var current_scene_path: String = "uid://c7hc705w0hq2y" # default to level menu
var previous_scene_path: String = "uid://c7hc705w0hq2y" # default to level menu

const menu_screen_uid: String = "uid://c7hc705w0hq2y"

func change_scene(scene_path) -> void:
	var loading_screen = load(loading_screen_uid).instantiate() as LoadingScreen
	loading_screen.scene_path = scene_path
	get_tree().change_scene_to_node(loading_screen)


func return_to_menu() -> void:
	var menu_screen = load(menu_screen_uid)
	get_tree().paused = false
	get_tree().change_scene_to_packed.call_deferred(menu_screen)


func update_current_scene_path(scene_path: String) -> void:
	if scene_path == loading_screen_uid:
		push_warning("some kinda loading screen loop")
	previous_scene_path = current_scene_path
	current_scene_path = scene_path


func return_to_previous_scene() -> void:
	change_scene(previous_scene_path)
