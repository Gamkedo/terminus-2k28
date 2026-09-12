extends Node
class_name MenuButtonAudio

const BUTTON_HOVER_STEAM: AudioStream = preload("res://Sound Effects/UI/UI_tone_1.wav")
const BUTTON_SELECT_STEAM: AudioStream = preload("res://Sound Effects/UI/UI_click_2.wav")

static var _button_signal_audio_streams: Dictionary[StringName, AudioStream]

func _ready() -> void:
	assign_all_menu_button_audio()

func assign_all_menu_button_audio() -> void:
	var buttons: Array[Node] = get_parent().find_children("*", "BaseButton", true, false)
	for button in buttons:
		button.pressed.connect(_on_button_event.bind(button, &"pressed"))
		button.mouse_entered.connect(_on_button_event.bind(button, &"mouse_entered"))
		
		var select_stream_key: StringName = button.name + "|" + "pressed"
		_button_signal_audio_streams[select_stream_key] = BUTTON_SELECT_STEAM
		
		var hover_stream_key: StringName = button.name + "|" + "mouse_entered"
		_button_signal_audio_streams[hover_stream_key] = BUTTON_HOVER_STEAM
	
func _on_button_event(button: Button, signal_name: String) -> void:
	var stream_key: StringName = button.name + "|" + signal_name
	if stream_key:
		var button_stream: AudioStream = _button_signal_audio_streams[stream_key]
	
		AudioStreamManager.play_sfx(button_stream.resource_path)
	
