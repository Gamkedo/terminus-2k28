extends Node

# based on method covered at:
# https://www.youtube.com/watch?v=ejRXpRlFa_Y

@export var end_anim: AnimationPlayer
@onready var label = $TimerLabel
@onready var timer = $TimerKeeper

var finished := false

func _ready():
	timer.start()

func _process(delta):
	if finished:
		return
		
	if timer.time_left <= 0.0:
		label.text = "RESCUE COMING!"
		end_anim.play("rescue")
		finished = true
	else:
		label.text = "SURVIVE: %02d" % int(timer.time_left)
