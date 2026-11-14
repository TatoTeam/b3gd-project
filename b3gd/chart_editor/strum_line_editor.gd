extends Node

@export var strum_line_scene: PackedScene

@onready var chart_loader = get_tree().get_first_node_in_group("ChartLoader")
@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")
@onready var strum_lines_parent = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%StrumLineContainer")
@onready var note_class_box = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%NoteClass")

@onready var action_player = %ActionPlayer

@onready var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var snap_slider: SpinSlider = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%Snap")
@onready var zoom_slider: SpinSlider = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%Zoom")

var zoom = 0
var song_progress_seconds = 0

func _ready() -> void:
	replace_strum_lines()
	snap_slider.value_changed.connect(snap_changed)

func _process(_delta: float) -> void:
	zoom = zoom_slider.value
	song_progress_seconds = song_audio_player.song_progress_seconds

func replace_strum_lines():
	for child in strum_lines_parent.get_children():
		strum_lines_parent.remove_child(child)
		child.free()
	
	for idx in chart_source.chart.strum_lines.size():
		var strum_line_node = strum_line_scene.instantiate()
		strum_line_node.strum_line_manager = self
		strum_line_node.strum_line_idx = idx
		strum_line_node.try_create_note.connect(try_create_note)
		strum_line_node.try_remove_note.connect(try_remove_note)
		
		strum_line_node.add_receptor.connect(add_receptor.bind(idx))
		strum_line_node.remove_receptor.connect(remove_receptor.bind(idx))
		
		strum_lines_parent.add_child(strum_line_node)
	
	await get_tree().process_frame
	for strum_line in strum_lines_parent.get_children():
		strum_line.strum_line_set_cpu.connect(set_cpu.bind(strum_line.strum_line_idx))

func try_create_note(strum_line: int, receptor: int, time: float, length: float):
	
	try_remove_note(strum_line, receptor, time)
	
	var new_note = load(note_class_box.class_paths[note_class_box.selected]).new()
	new_note.time = time
	new_note.length = length
	action_player.do_action({
		"type": action_player.ActionType.ADD_NOTE,
		"strum_line": strum_line,
		"receptor": receptor,
		"note": new_note
	})

func try_remove_note(strum_line: int, receptor: int, time: float, do_action: bool = true):
	for note in chart_source.chart.strum_lines[strum_line].receptors[receptor].notes:
		if abs(note.time - time) > 0.000001:
			continue
		var action = {
			"type": action_player.ActionType.REMOVE_NOTE,
			"strum_line": strum_line,
			"receptor": receptor,
			"note": note
		}
		if do_action:
			action_player.do_action(action)
		return action

func remove_receptor(idx: int) -> void:
	action_player.do_action({
		"type": action_player.ActionType.REMOVE_RECEPTOR,
		"index": idx
	})

func add_receptor(idx: int) -> void:
	action_player.do_action({
		"type": action_player.ActionType.ADD_RECEPTOR,
		"index": idx
	})

func set_cpu(toggled: bool, idx: int) -> void:
	action_player.do_action({
		"type": action_player.ActionType.SET_STRUMLINE_CPU,
		"index": idx,
		"cpu": toggled
	})

func _on_action_player_notes_changed() -> void:
	for strum_line in strum_lines_parent.get_children():
		strum_line.update_strum_line()
		strum_line.notes.update.call_deferred()
		strum_line.force_update_zoom = true

func _on_action_player_events_changed() -> void:
	for strum_line in strum_lines_parent.get_children():
		strum_line.grid.update.call_deferred()

func snap_changed(_value) -> void:
	for strum_line in strum_lines_parent.get_children():
		strum_line.grid.update.call_deferred()

func strum_line_changed(idx: int) -> void:
	var strum_line = strum_lines_parent.get_children()[idx]
	strum_line.update_strum_line()
	strum_line.receptors.update()
	strum_line.info.update()
	strum_line.notes.update()
	strum_line.force_update_zoom = true

func strum_lines_changed() -> void:
	replace_strum_lines()
