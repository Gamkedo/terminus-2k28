extends Node

# based on method covered at:
# https://www.youtube.com/watch?v=ejRXpRlFa_Y

@onready var label = $TimerLabel
@onready var timer = $TimerKeeper

func _ready():
	timer.start()

func _process(delta):
	if timer.time_left <= 0.0:
		label.text = "RESCUE COMING!"
	else:
		label.text = "SURVIVE: %02d" % int(timer.time_left)
