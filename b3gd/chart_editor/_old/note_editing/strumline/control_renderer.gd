extends Control

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var note_manager := get_tree().get_first_node_in_group("NoteManager")
@onready var scroll_zoom = get_parent().get_parent().get_node("%EditorScrollZoom")
@onready var strum_label: Label = get_parent().get_node("%StrumLineLabel")
