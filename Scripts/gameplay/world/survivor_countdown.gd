extends Node

# based on method covered at:
# https://www.youtube.com/watch?v=ejRXpRlFa_Y

@onready var label = $TimerLabel
@onready var timer = $TimerKeeper

func _ready():
	timer.start()

func _process(delta):
	label.text = "SURVIVE: %02d" % int(timer.time_left)
