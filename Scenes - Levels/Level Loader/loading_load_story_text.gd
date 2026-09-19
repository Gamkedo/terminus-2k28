extends Label

@export var scene_loading: LoadingScreen

func _ready() -> void:
	if "Arcade" in scene_loading.scene_path:
		text = "Frozen in 1990 and now awake in 2028, our hero - Sgt. Valentine Wakefield - must escape Cryosleep before a system collapse."
	elif "Survivor" in scene_loading.scene_path:
		text = "Sgt. Valentine Wakefield beats back against this new hellscape spawning creatures that need him dead. 
Deep in the distant sky, a crackle of hope splits through."
	elif "Immersive" in scene_loading.scene_path:
		text = "Sgt. Valentine Wakefield battles to deliver his heart for a transplant to his ailing scientist son Dr. Mike Wakefield."
	else: # no loading scene text
		text = ""
