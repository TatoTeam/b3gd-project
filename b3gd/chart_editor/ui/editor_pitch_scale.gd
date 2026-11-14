extends SpinSlider

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")

func _ready() -> void:
	if song_audio_player == null:
		printerr("SongAudioPlayer does not exist.")
		return
	value = song_audio_player.pitch_scale

func _on_value_changed(val: float) -> void:
	if song_audio_player == null:
		return
	song_audio_player.pitch_scale = val
