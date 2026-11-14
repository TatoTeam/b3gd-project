extends Node

@onready var chart_loader = get_tree().get_first_node_in_group("ChartLoader")
@onready var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")
@onready var note_manager = get_tree().get_first_node_in_group("NoteManager")
@onready var hit_sound_player = $NoteClick

var hit_note_ids: Array[Array] = []

func _ready() -> void:
	init_hit_notes()

func init_hit_notes():
	var strum_lines = chart_source.chart.strum_lines
	hit_note_ids = []
	hit_note_ids.resize(strum_lines.size())
	
	for strum_line_id in strum_lines.size():	
		for receptor_id in strum_lines[strum_line_id].receptors.size():
			hit_note_ids[strum_line_id].append(-1)
			for note_id in strum_lines[strum_line_id].receptors[receptor_id].notes.size():
				var note_to_hit = strum_lines[strum_line_id].receptors[receptor_id].notes[note_id]
				
				if note_to_hit.time <= song_audio_player.song_progress_seconds:
					hit_note_ids[strum_line_id][-1] = note_id

func _process(_delta: float) -> void:
	for strum_line_id in range(chart_source.chart.strum_lines.size()):
		for receptor_id in chart_source.chart.strum_lines[strum_line_id].receptors.size():
			while handle_note(strum_line_id, receptor_id):
				continue

func handle_note(strum_line_id, receptor_id) -> bool:
	var receptor = chart_source.chart.strum_lines[strum_line_id].receptors[receptor_id]
	var current_note_id = hit_note_ids[strum_line_id][receptor_id]
	var current_time = song_audio_player.song_progress_seconds
	
	if receptor.notes.size() == 0:
		return false
	
	if current_note_id >= receptor.notes.size():
		hit_note_ids[strum_line_id][receptor_id] -= 1
		return false
	
	if current_note_id >= 0 and !receptor.notes[current_note_id].time <= current_time:
		hit_note_ids[strum_line_id][receptor_id] -= 1
		return false
	
	if current_note_id + 1 >= receptor.notes.size():
		return false
	
	var next_note = receptor.notes[current_note_id + 1]
	
	if next_note.time <= current_time:
		hit_note_ids[strum_line_id][receptor_id] = current_note_id + 1
		note_manager.note_press.emit(strum_line_id, receptor_id, next_note, 0.0)
		
		var vocal_layer = chart_loader.vocal_layers[strum_line_id]
		if song_audio_player.stream.get_sync_stream_volume(vocal_layer) > -20:
			hit_sound_player.play()
	
	return next_note.time <= current_time


func strum_line_changed(_idx: int) -> void:
	init_hit_notes()

func strum_lines_changed() -> void:
	init_hit_notes()
