extends Node2D

@export var quant_colors: PackedColorArray

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var song_scrubber = get_tree().get_first_node_in_group("ChartEditor").get_node("%SongScrubber")
@onready var strum_line_rect = get_parent().get_parent()

signal try_create_note(strum_line_id: int, receptor: int, time: float, length: float)
signal try_remove_note(strum_line_id: int, receptor: int, time: float)

var is_mouse_over = false
var mouse_column: int = -1
var mouse_time: float = 0.0

var creating_note = false
var note_length = 0.0

@onready var note = $ScaleOrigin/Note
@onready var note_color = $ScaleOrigin/Note/Color
@onready var hold = $Hold
@onready var hold_color = $Hold/Color
@onready var receptors = %Receptors


func _ready() -> void:
	note.texture = note.texture.duplicate_deep()
	hold.texture = hold.texture.duplicate_deep()
	note_color.texture = note_color.texture.duplicate_deep()

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	var strum_line_id = int(%StrumLineLabel.text)
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			if event.is_pressed() and is_mouse_over:
				creating_note = true
				note_length = 0.0
			if event.is_released() and creating_note:
				creating_note = false
				try_create_note.emit(strum_line_id, mouse_column, mouse_time, note_length)
		MOUSE_BUTTON_RIGHT:
			if !event.is_pressed() or !is_mouse_over:
				return
			try_remove_note.emit(strum_line_id, mouse_column, mouse_time)

func _process(_delta: float) -> void:
	var mouse_rect_position = strum_line_rect.get_local_mouse_position()
	is_mouse_over = Rect2(Vector2.ZERO, strum_line_rect.size).has_point(mouse_rect_position)
	if is_mouse_over:
		var scroll_area = strum_line_rect.get_parent().get_parent().get_node("%WorkAreaScroll")
		var scroll_local_mouse_pos = scroll_area.get_local_mouse_position()
		is_mouse_over = Rect2(Vector2.ZERO, scroll_area.size).has_point(scroll_local_mouse_pos)
	
	var local_mouse_position = get_parent().get_local_mouse_position()
	
	var time_mouse_pos = local_mouse_position.y / 64
	time_mouse_pos = song_scrubber.get_snapped_seconds(time_mouse_pos)
	
	if creating_note:
		note_length = max(time_mouse_pos - mouse_time, 0)
	else:
		mouse_time = time_mouse_pos
		mouse_column = floor(local_mouse_position.x / 64)
	
	if !is_mouse_over and !creating_note:
		hide()
	show()
	
	#if mouse_column < 0:
	#	is_mouse_over = false
	#	return
	#if mouse_column >= receptors.current_key_indexes.size():
	#	is_mouse_over = false
	#	return
	var note_image_id = receptors.current_key_indexes[clamp(mouse_column, 0, receptors.current_key_indexes.size() - 1)]
	
	note.texture.region.position.x = note_image_id * 64
	note_color.texture.region.position.x = note_image_id * 64
	hold.texture.region.position.x = note_image_id * 64
	position.x = mouse_column * 64
	position.y = mouse_time * 64
	
	var quant_color = quant_colors[get_quant_id(mouse_time)]
	note_color.modulate = quant_color
	hold_color.modulate = quant_color
	if !creating_note:
		hold.hide()
		return
	hold.show()
	hold.scale.y = note_length

const QUANT_LIST = [4,8,12,16,24,32,48,64]

func get_quant_id(note_time):
	var note_beat = song_audio_player.get_beat_from_seconds(note_time)
	var note_beat_sm: int = round(note_beat * 48.0)
	for i in QUANT_LIST.size():
		if note_beat_sm % (192 / QUANT_LIST[i]) == 0:
			return i
	return 8
