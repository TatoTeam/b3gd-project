extends Node

@onready var chart_source:Node = get_tree().get_first_node_in_group("ChartSource")

func add(strum_line: int, receptor: int, note: Note):
	var note_location = chart_source.chart.strum_lines[strum_line].receptors[receptor].notes
	note_location.append(note)
	note_location.sort_custom(sort_ascending)
	get_parent().notes_changed.emit()

func remove(strum_line: int, receptor: int, note: Note):
	var note_location = chart_source.chart.strum_lines[strum_line].receptors[receptor].notes
	note_location.erase(note)
	get_parent().notes_changed.emit()

func move(strum_line: int, receptor: int, note: Note, new_time: float):
	var note_location = chart_source.chart.strum_lines[strum_line].receptors[receptor].notes
	var note_id = note_location.find(note)
	note_location[note_id].time = new_time
	note_location.sort_custom(sort_ascending)
	get_parent().notes_changed.emit()

func replace(strum_line: int, receptor: int, note: Note, new_note: Note):
	var note_location = chart_source.chart.strum_lines[strum_line].receptors[receptor].notes
	var note_id = note_location.find(note)
	note_location[note_id] = new_note
	note_location.sort_custom(sort_ascending)
	get_parent().notes_changed.emit()

func sort_ascending(a, b):
	if is_equal_approx(a.time, b.time) and a is Event:
		return a.lane < b.lane
	return a.time < b.time
