extends Label

@export var scene_loading: LoadingScreen

func _ready() -> void:
	if "Arcade" in scene_loading.scene_path:
		text = "The creators of the machines want you to stay asleep.\n\nIn order to wake up, the first battle is in cyberspace."
	elif "Survivor" in scene_loading.scene_path:
		text = "Your mind is free. They're coming for you.\n\nSurvive until the resistance can airlift you out.\n\nAutofire, autoaim, and weapon stacking activated."
	elif "Immersive" in scene_loading.scene_path:
		text = "We've dropped you off at the data center.\n\nFinish the mission.\n\nSwitching to precision mode"
	else: # no loading scene text
		text = ""
