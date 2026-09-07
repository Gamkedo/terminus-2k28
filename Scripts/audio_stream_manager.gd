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

const MASTER_BUS: StringName = &"Master"
const SFX_BUS: StringName = &"sfx"
const BGM_BUS: StringName = &"bgm"

enum PlaybackMode {STANDARD, RANDOM_PITCH, ASCENDING_PITCH, DESCENDING_PITCH}

var num_players := 7 # maximum sfx that can play at once
var max_in_queue := 10 # more than 20 sounds in queue will drop the last sound

var bgm_player
var available: Array[AudioStreamPlayer] = []
var queue: Array[Dictionary] = []

var acsending_starting_pitch := 0.8
var ascending_pitch = acsending_starting_pitch
var ascending_pitch_increment := 0.05
var ascending_timer

var descending_starting_pitch := 1.2
var descending_pitch = descending_starting_pitch
var descending_pitch_decrement := 0.05
var descending_timer

var bg_music_tracks: Array[AudioStream] = [
	preload("uid://dwrnljiewp65j"),
	preload("uid://ckf2bo2btl6yy"),
]
var selected_background_music: AudioStream = bg_music_tracks[0]

func _ready() -> void:
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.finished.connect(_on_sfx_stream_finished.bind(p))
		p.bus = SFX_BUS
	
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = BGM_BUS
	bgm_player.process_mode = PROCESS_MODE_ALWAYS
	_create_timer_nodes()

func select_background_track(i: int) -> void:
	if abs(i) < bg_music_tracks.size():
		selected_background_music = bg_music_tracks[i]
		play_selected_track()
	else: push_error("Music track[" + str(i) + "/ + " + str(bg_music_tracks.size()) + "] out of bounds!")

func play_selected_track() -> void:
	assert(selected_background_music, "selected_background_music is null or invalid!")
	if selected_background_music:
		play_bgm(selected_background_music)

func _on_sfx_stream_finished(stream: AudioStreamPlayer):
	available.append(stream)

func play_sfx(sound_path: String, playback_mode: PlaybackMode = PlaybackMode.STANDARD):
	if muted: return
	if queue.size() >= max_in_queue:
		queue.pop_back()
	queue.append({"playback_mode": playback_mode, "sound_path": sound_path})


func play_bgm(sound: AudioStream) -> void:
	if muted: return
	bgm_player.stream = sound
	bgm_player.play()

@onready var muted: bool = false:
	set(v):
		muted = v
		if muted: bgm_player.stop()
		else: play_selected_track()

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("mute_game")):
		const MASTER_BUS_IDX = 0 #AudioServer.get_bus_index(MASTER_BUS) # master is always index 0...
		var muteState = AudioServer.is_bus_mute(MASTER_BUS_IDX)
		AudioServer.set_bus_mute(MASTER_BUS_IDX, not muteState)

func _process(_delta: float):
	if muted: return

	## Play sfx
	if not queue.is_empty() and not available.is_empty():
		var sound = queue.pop_front()
		match sound["playback_mode"]:
			PlaybackMode.STANDARD:
				available[0].stream = load(sound["sound_path"])
				available[0].play()
				available.pop_front()
			## Play sfx with a random pitch
			PlaybackMode.RANDOM_PITCH:
				available[0].stream = load(sound["sound_path"])
				available[0].pitch_scale = randf_range(0.8,1.2)
				available[0].play()
				available.pop_front()
			## Play sfx with an ascending pitch
			PlaybackMode.ASCENDING_PITCH:
				available[0].stream = load(sound["sound_path"])
				available[0].pitch_scale = ascending_pitch
				ascending_pitch += ascending_pitch_increment
				ascending_timer.start()
				available[0].play()
				available.pop_front()
			## Play sfx with a descreasing pitch
			PlaybackMode.DESCENDING_PITCH:
				available[0].stream = load(sound["sound_path"])
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
