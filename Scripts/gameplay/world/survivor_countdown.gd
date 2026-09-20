extends Node

# based on method covered at:
# https://www.youtube.com/watch?v=ejRXpRlFa_Y

@export var end_anim: AnimationPlayer
@onready var label = $TimerLabel
@onready var timer = $TimerKeeper

var finished := false

func _ready():
	timer.start()

func start_rescue_sound():
	AudioStreamManager.play_sfx("res://Sound Effects/Spaceship/spaceship_flyby.wav", AudioStreamManager.PlaybackMode.STANDARD)

# should probably handle more gracefully (game over?) but in the meantime can't trap testers
func back_to_menu():
	SceneChanger.change_scene("res://level_menu.tscn")

func _process(delta):
	if finished:
		return
		
	if timer.time_left <= 0.0:
		GameGlobal.won_surv = true
		label.text = "RESCUE COMING!"
		end_anim.play("rescue")
		finished = true
	else:
		label.text = "SURVIVE: %02d" % int(timer.time_left)
