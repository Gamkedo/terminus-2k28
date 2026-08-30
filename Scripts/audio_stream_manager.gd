extends Node

#####
# AudioStreamManager
# This is a global available via Autoload.
# To play a new background track, call AudioStreamManager.play_bgm("res://path/to/song.wav")
# To play a new sound effect, call AudioStreamManager.play_sfx("res://path/to/sfx.wav")
# There are a maximum number of sfx that can be played at once. Additional ones will be added to a queue
#
# Potential Enhancements:
# - Drop sound effects
# - Support for preloaded streams instead of paths
#####

var num_players := 7 # maximum sfx that can play at once

var bgm_player
var available: Array[AudioStreamPlayer] = []
var queue: Array[String] = []

func _ready() -> void:
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.finished.connect(_on_sfx_stream_finished.bind(p))
		p.bus = "sfx"
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "bgm"
	bgm_player.process_mode = PROCESS_MODE_ALWAYS
	
func _on_sfx_stream_finished(stream: AudioStreamPlayer):
	available.append(stream)

func play_sfx(sound_path: String):
	queue.append(sound_path)

func play_bgm(sound_path: String):
	bgm_player.stream = load(sound_path)
	bgm_player.play()

func _process(_delta: float):
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()
