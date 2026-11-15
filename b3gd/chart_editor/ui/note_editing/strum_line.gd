extends VBoxContainer
class_name EditorStrumLine

const TIMELINE_PRESENT_POINT = 0.333

var strum_line_manager: Node
var strum_line_idx = 0
var current_time = 0
var zoom = 1.0
var strum_line: StrumLine

signal try_create_note(strum_line_id: int, receptor: int, time: float, length: float)
signal try_remove_note(strum_line_id: int, receptor: int, time: float)

signal add_receptor
signal remove_receptor

@warning_ignore("unused_signal") # called from InfoPanel
signal strum_line_set_cpu(toggle: bool)


@onready var timeline_root = %TimelineRoot
@onready var receptors = %Receptors
@onready var grid = %TimelineRoot/Grid
@onready var notes = %TimelineRoot/Notes
@onready var input = %TimelineRoot/NoteInput
@onready var info = $InfoPanel
@onready var strum_line_parent = $StrumLineParent

var force_update_zoom = false

func _ready() -> void:
	input.try_create_note.connect(emit_try_create_note)
	input.try_remove_note.connect(emit_try_remove_note)
	
	update_strum_line()
	info.update()
	receptors.update()
	grid.update()
	notes.update()

var transform_y = size.y

func update_strum_line():
	strum_line = strum_line_manager.chart_source.chart.strum_lines[strum_line_idx]
	$StrumLineParent.custom_minimum_size.x = 64 * strum_line.receptors.size()

func _process(_delta: float) -> void:
	current_time = strum_line_manager.song_progress_seconds
	var old_zoom = zoom
	zoom = strum_line_manager.zoom
	
	transform_y = get_viewport_rect().size.y
	transform_y *= TIMELINE_PRESENT_POINT
	
	timeline_root.global_position.y = transform_y - (current_time * zoom * 64)
	receptors.global_position.y = transform_y
	
	if old_zoom == zoom and !force_update_zoom:
		return
	force_update_zoom = false
	
	timeline_root.scale.y = zoom
	grid.scale.x = size.x
	receptors.scale.y = min(zoom, 1.0)
	
	for line in grid.get_children():
		line.scale.y = clamp(1.0 * timeline_root.scale.y, 1.0, 3.0) / timeline_root.scale.y
	for note in notes.get_children():
		note.get_children()[0].scale.y = min(1.0 / timeline_root.scale.y, 1.0)
	
	input.get_node("ScaleOrigin").scale.y = min(1.0 / timeline_root.scale.y, 1.0)

func emit_try_create_note(...args: Array):
	try_create_note.emit.callv(args)

func emit_try_remove_note(...args: Array):
	try_remove_note.emit.callv(args)

func remove_receptor_pressed() -> void:
	remove_receptor.emit()

func add_receptor_pressed() -> void:
	add_receptor.emit()

func _on_mute_check_box_toggled(toggled_on: bool) -> void:
	var vocal_layer = strum_line_manager.chart_loader.vocal_layers[strum_line_idx]
	var volume = -50 if toggled_on else 0
	strum_line_manager.song_audio_player.stream.set_sync_stream_volume(vocal_layer, volume)


func _on_cpu_check_box_toggled(toggled_on: bool) -> void:
	strum_line_set_cpu.emit(toggled_on)
