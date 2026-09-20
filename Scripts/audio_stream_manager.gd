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
const LIGHTNING_BUS: StringName = &"lightning"

const LIGHTNING_LOOP_RELATIVE_VOLUME = 0.6
const LIGHTNING_VOL_CHANGE_PACE = 2.5 # multiplier on delta towards or down from 1.0

enum PlaybackMode {STANDARD, RANDOM_PITCH, ASCENDING_PITCH, DESCENDING_PITCH}

var num_players := 7 # maximum sfx that can play at once
var max_in_queue := 10 # more than 20 sounds in queue will drop the last sound

var bgm_player: AudioStreamPlayer
var game_over_player: AudioStreamPlayer
var lightning_loop_player: AudioStreamPlayer
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

var _global_volume: float = 1.0

var lightning_firing:bool = false
var lightning_held_time: float = 0.0 # for ramp up and cool down

var bg_music_tracks: Array[AudioStream] = [
	preload("uid://dwrnljiewp65j"),
	preload("uid://ckf2bo2btl6yy"),
	preload("uid://daf5fwio2kfr0"),
]

var sound_preload_attempt: Array[AudioStream] = [
	preload("uid://dloj8eqy78k88"), # res://Sound Effects/Electricity/electricity_one_shot_v2.wav
	preload("uid://bkgs7qplm88a2"), # UI/UI_rumble.wav
	preload("uid://b6de3bc3fgdnh"), # Explosions/explosion_4.wav
	preload("uid://c0ehc4qrivpgx"), # survivors pickup sound
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
	bgm_player.volume_linear = _global_volume
	add_child(bgm_player)
	bgm_player.bus = BGM_BUS
	bgm_player.process_mode = PROCESS_MODE_ALWAYS
	
	lightning_loop_player = AudioStreamPlayer.new()
	lightning_loop_player.volume_linear = 0.0 # starts silent
	add_child(lightning_loop_player)
	lightning_loop_player.bus = LIGHTNING_BUS
	lightning_loop_player.process_mode = PROCESS_MODE_ALWAYS
	lightning_loop_player.stream = load("res://Sound Effects/Electricity/electricity_staggered_loop.wav")
	lightning_loop_player.play()
	
	game_over_player = AudioStreamPlayer.new()
	game_over_player.volume_linear = _global_volume
	add_child(game_over_player)
	game_over_player.bus = SFX_BUS
	game_over_player.process_mode = PROCESS_MODE_ALWAYS
	_create_timer_nodes()

func lightning_loop_update(isFiring: bool, power_level:int) -> void:
	lightning_firing = isFiring
	lightning_loop_player.pitch_scale = 0.85 + 0.1 * power_level
	
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

func play_game_over(sound: AudioStream) -> void:
	if muted or game_over_player.playing: return
	game_over_player.stream = sound
	game_over_player.play()


var faded_bgm_from: float = 1.0

func fade_out_music(seconds = 1.0) -> Tween:
	faded_bgm_from = get_music_volume()
	var t := create_tween()
	t.tween_method(set_music_volume, faded_bgm_from, 0.0, seconds)
	return t

func fade_in_music(seconds = 1.0) -> Tween:
	var t := create_tween()
	t.tween_method(set_music_volume, get_music_volume(), faded_bgm_from, seconds)
	return t

func restore_bgm_volume() -> void:
	set_music_volume(faded_bgm_from)

func set_music_volume(linear_value: float) -> void:
	var idx = AudioServer.get_bus_index(BGM_BUS)
	AudioServer.set_bus_volume_linear(idx, linear_value)

func get_music_volume() -> float:
	var idx = AudioServer.get_bus_index(BGM_BUS)
	return AudioServer.get_bus_volume_linear(idx)

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

	if lightning_firing:
		lightning_held_time += _delta * LIGHTNING_VOL_CHANGE_PACE
		if lightning_held_time>1.0:
			lightning_held_time = 1.0
	else:
		lightning_held_time -= _delta * LIGHTNING_VOL_CHANGE_PACE
		if lightning_held_time<0.0:
			lightning_held_time = 0.0
	lightning_loop_player.volume_linear = _global_volume * LIGHTNING_LOOP_RELATIVE_VOLUME * lightning_held_time


	## Play sfx
	if not queue.is_empty() and not available.is_empty():
		var sound = queue.pop_front()
		available[0].stream = load(sound["sound_path"])
		match sound["playback_mode"]:
			PlaybackMode.STANDARD:
				pass
			## Play sfx with a random pitch
			PlaybackMode.RANDOM_PITCH:
				available[0].pitch_scale = randf_range(0.8,1.2)
			## Play sfx with an ascending pitch
			PlaybackMode.ASCENDING_PITCH:
				available[0].pitch_scale = ascending_pitch
				ascending_pitch += ascending_pitch_increment
				ascending_timer.start()
			## Play sfx with a descreasing pitch
			PlaybackMode.DESCENDING_PITCH:
				available[0].pitch_scale = descending_pitch
				descending_pitch -= descending_pitch_decrement
				descending_timer.start()
		available[0].volume_linear = available[0].volume_linear * _global_volume
		available[0].play()
		available.pop_front()


func set_global_volume(vol: float):
	_global_volume = vol
	bgm_player.volume_linear = _global_volume
	game_over_player.volume_linear = _global_volume
	lightning_loop_player.volume_linear = 0.0 # next shot will recalculate


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
