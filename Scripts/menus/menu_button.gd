extends BaseButton

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	grab_focus()

func _on_mouse_exited() -> void:
	release_focus()
