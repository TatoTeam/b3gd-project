extends Control

var timeline_present_point = 0.333

@onready var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var song_scrubber = get_tree().get_first_node_in_group("ChartEditor").get_node("%SongScrubber")
@onready var zoom_slider: SpinSlider = %Zoom

@onready var events = $Events
@onready var event_maker = $EventMaker

func _process(delta: float) -> void:
	var zoom = zoom_slider.value
	var transform_y = get_viewport_rect().size.y
	transform_y *= timeline_present_point
	global_position.y = transform_y - (song_audio_player.song_progress_seconds * zoom * 64)
	scale.y = zoom
	for event in events.get_children():
		event.scale.y = 1.0 / scale.y
		event.get_node("Arrow").size.x = -position.x
	
	if event_maker == null:
		return
	
	event_maker.scale.y = 1.0 / scale.y
