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

enum PlaybackMode {STANDARD, RANDOM_PITCH, ASCENDING_PITCH, DESCENDING_PITCH}

var num_players := 7 # maximum sfx that can play at once

var bgm_player
var available: Array[AudioStreamPlayer] = []
var queue: Array[String] = []
var queue_random: Array[String] = []

var queue_ascending: Array[String] = []
var acsending_starting_pitch := 0.8
var ascending_pitch = acsending_starting_pitch
var ascending_pitch_increment := 0.05
var ascending_timer

var queue_descending: Array[String] = []
var descending_starting_pitch := 1.2
var descending_pitch = descending_starting_pitch
var descending_pitch_decrement := 0.05
var descending_timer

var bg_music_tracks: Array[String] = [
	"res://Music/ambience_a.ogg",
	"res://Music/terminus1_vorbis.ogg"
]
var selected_background_music: String = bg_music_tracks[0]

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
	_create_timer_nodes()

func select_background_track(i: int) -> void:
	if abs(i) < bg_music_tracks.size():
		selected_background_music = bg_music_tracks[i]
		play_selected_track()
	else: push_error("Music track[" + str(i) + "/ + " + str(bg_music_tracks.size()) + "] out of bounds!")

func play_selected_track() -> void:
	if FileAccess.file_exists(selected_background_music):
		play_bgm(selected_background_music)
	else: push_error("Music track(" + selected_background_music + ") doesn't exist!")

func _on_sfx_stream_finished(stream: AudioStreamPlayer):
	available.append(stream)

func play_sfx(sound_path: String, playback_mode: PlaybackMode = PlaybackMode.STANDARD):
	if muted: return
	match playback_mode:
		PlaybackMode.STANDARD:
			queue.append(sound_path)
		PlaybackMode.RANDOM_PITCH:
			queue_random.append(sound_path)
		PlaybackMode.ASCENDING_PITCH:
			queue_ascending.append(sound_path)
		PlaybackMode.DESCENDING_PITCH:
			queue_descending.append(sound_path)


func play_bgm(sound_path: String) -> void:
	if muted: return
	bgm_player.stream = load(sound_path)
	bgm_player.play()

@onready var muted: bool = false:
	set(v):
		muted = v
		if muted: bgm_player.stop()
		else: play_selected_track()

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("mute_game")):
		var busIdx = AudioServer.get_bus_index("Master")
		var muteState = AudioServer.is_bus_mute(busIdx)
		AudioServer.set_bus_mute(busIdx, not muteState)

func _process(_delta: float):
	if muted: return

	## Play sfx
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()
	## Play sfx with a random pitch
	if not queue_random.is_empty() and not available.is_empty():
		available[0].stream = load(queue_random.pop_front())
		available[0].pitch_scale = randf_range(0.8,1.2)
		available[0].play()
		available.pop_front()
	## Play sfx with an ascending pitch
	if not queue_ascending.is_empty() and not available.is_empty():
		available[0].stream = load(queue_ascending.pop_front())
		available[0].pitch_scale = ascending_pitch
		ascending_pitch += ascending_pitch_increment
		ascending_timer.start()
		available[0].play()
		available.pop_front()
	## Play sfx with a descreasing pitch
	if not queue_descending.is_empty() and not available.is_empty():
		available[0].stream = load(queue_descending.pop_front())
		available[0].pitch_scale = descending_pitch
		descending_pitch -= descending_pitch_decrement
		available[0].play()
		available.pop_front()


func _create_timer_nodes() -> void:
	ascending_timer = Timer.new()
	add_child(ascending_timer)
	ascending_timer.timeout.connect(_on_ascending_sfx_timeout)
	descending_timer = Timer.new()
	add_child(descending_timer)
	descending_timer.timeout.connect(_on_descending_sfx_timeout)


func _on_ascending_sfx_timeout() -> void:
	ascending_pitch = acsending_starting_pitch

func _on_descending_sfx_timeout() -> void:
	descending_pitch = descending_starting_pitch
