extends CheckBox

@onready var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")

func _toggled(toggled_on: bool) -> void:
	var volume = -50 if toggled_on else 0
	song_audio_player.stream.set_sync_stream_volume(0, volume)
