extends Control

func _on_music_button_toggled(toggled_on: bool) -> void:
	AudioStreamManager.muted = toggled_on

func _ready() -> void:
	for track in AudioStreamManager.bg_music_tracks:
		%MusicSelector.add_item(track.get_file().get_basename())
	if 0 < AudioStreamManager.bg_music_tracks.size(): %MusicSelector.selected = 0

func _on_music_selector_item_selected(index: int) -> void:
	AudioStreamManager.select_background_track(index)
