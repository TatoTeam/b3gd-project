extends Control
class_name EditorStrumlineDrawer

const NOTES: CompressedTexture2D = preload("uid://bdkks2vfqiwwd")
const NOTECOLOR: CompressedTexture2D = preload("uid://p6quxyfjutej")
const QUANT_LIST := [4, 8, 12, 16, 24, 32, 48, 64]

# lazy
static var QUANT_COLORS: Array[Color] = [
	Color.from_string("e01e00", Color.BLACK),
	Color.from_string("003fed", Color.BLACK),
	Color.from_string("8300e0", Color.BLACK),
	Color.from_string("4ab50d", Color.BLACK),
	Color.from_string("db1fd2", Color.BLACK),
	Color.from_string("e0bb00", Color.BLACK),
	Color.from_string("e67cb1", Color.BLACK),
	Color.from_string("48d9c3", Color.BLACK),
	Color.from_string("999999", Color.BLACK)
]

const NOTE_TEXTURE_ARRAYS := {
	1: [4],
	2: [5, 8],
	3: [0, 4, 3],
	4: [0, 1, 2, 3],
	5: [0, 1, 4, 2, 3],
	6: [0, 1, 3, 0, 2, 3],
	7: [0, 1, 3, 4, 0, 2, 3],
	8: [0, 1, 2, 3, 0, 1, 2, 3],
	9: [0, 1, 2, 3, 4, 0, 1, 2, 3],
	10: [0, 1, 2, 3, 5, 8, 0, 1, 2, 3],
	11: [0, 1, 2, 3, 5, 9, 8, 0, 1, 2, 3],
	12: [0, 1, 2, 3, 5, 6, 7, 8, 0, 1, 2, 3],
	13: [0, 1, 2, 3, 5, 6, 4, 7, 8, 0, 1, 2, 3],
	14: [0, 1, 2, 3, 5, 6, 8, 5, 7, 8, 0, 1, 2, 3],
	15: [0, 1, 2, 3, 5, 6, 8, 4, 5, 7, 8, 0, 1, 2, 3],
	16: [0, 1, 2, 3, 5, 6, 7, 8, 5, 6, 7, 8, 0, 1, 2, 3],
	17: [0, 1, 2, 3, 5, 6, 7, 8, 4, 5, 6, 7, 8, 0, 1, 2, 3],
	18: [0, 1, 2, 3, 5, 6, 7, 8, 0, 3, 5, 6, 7, 8, 0, 1, 2, 3],
	19: [0, 1, 2, 3, 5, 6, 7, 8, 0, 9, 3, 5, 6, 7, 8, 0, 1, 2, 3],
	20: [0, 1, 2, 3, 5, 6, 7, 8, 0, 1, 2, 3, 5, 6, 7, 8, 0, 1, 2, 3],
	21: [0, 1, 2, 3, 5, 6, 7, 8, 0, 1, 4, 2, 3, 5, 6, 7, 8, 0, 1, 2, 3],
	22: [10]
}

@onready var strumline_object: EditorStrumLine = $".."

var receptor_y_pos: float:
	get():
		return size.y * ChartEditor.inst.settings.receptor_offset

var pixels_per_second: float:
	get():
		return ChartEditor.inst.settings.NOTE_SIZE * ChartEditor.inst.settings.editor_zoom

static func get_note_vector_array(receptor_count: int) -> Array:
	if receptor_count > NOTE_TEXTURE_ARRAYS.size() - 1:
		return NOTE_TEXTURE_ARRAYS[22]
	else:
		return NOTE_TEXTURE_ARRAYS[receptor_count]

static func get_quant_id(note_time: float) -> int:
	var note_beat = ChartEditor.song_audio_player.get_beat_from_seconds(note_time)
	var note_beat_sm: int = round(note_beat * 48.0)
	for i in QUANT_LIST.size():
		if note_beat_sm % (192 / QUANT_LIST[i]) == 0:
			return i
	
	return 8

func _process(_delta):
	# honestly no reason not to do this here since notes will be usually redrawn every frame due to the song yknow.. playing
	queue_redraw()

func time_to_y(time: float) -> float:
	return receptor_y_pos + (time - ChartEditor.song_audio_player.song_progress_seconds) * pixels_per_second

func y_to_time(y: float) -> float:
	return ChartEditor.song_audio_player.song_progress_seconds + (y - receptor_y_pos) / pixels_per_second

func snap_time(time: float) -> float:
	var beat: float = ChartEditor.song_audio_player.get_beat_from_seconds(time)
	beat = snappedf(beat, 4.0 / ChartEditor.inst.settings.snapping)
	return ChartEditor.song_audio_player.get_seconds_from_beat(beat)

func get_note_position(dir: int, time: float) -> Vector2:
	var note_size := ChartEditor.inst.settings.NOTE_SIZE
	return Vector2(dir * note_size, time_to_y(time) - note_size / 2.0)

func get_note_source_rect(dir: int, row: int) -> Rect2:
	var texture_array := get_note_vector_array(strumline_object.strumline.receptors.size())
	var note_size := ChartEditor.inst.settings.NOTE_SIZE
	return Rect2(Vector2(texture_array[dir % texture_array.size()] * note_size, row * note_size), Vector2.ONE * note_size)



func draw_note(target: CanvasItem, dir: int, time: float, length: float, preview: bool = false) -> void:
	if strumline_object.strumline == null: return
	if dir < 0 || dir >= strumline_object.strumline.receptors.size(): return
	
	var note_size := ChartEditor.inst.settings.NOTE_SIZE
	var note_position := get_note_position(dir, time)
	var note_draw_rect := Rect2(Vector2.ZERO, Vector2.ONE * note_size)
	var source_rect := get_note_source_rect(dir, 1)
	var quant_color: Color = QUANT_COLORS[get_quant_id(time)]
	
	if preview:
		quant_color.a = 0.75
	
	target.draw_set_transform(note_position)
	_draw_note_region(target, note_draw_rect, source_rect, quant_color, preview)
	
	if length > 0.0:
		target.draw_set_transform(note_position + Vector2(0, note_size / 2.0))
		source_rect.position.y = note_size * 2
		note_draw_rect.size.y = length * pixels_per_second
		_draw_note_region(target, note_draw_rect, source_rect, quant_color, preview)
	
	target.draw_set_transform(Vector2.ZERO)

func _draw_note_region(target: CanvasItem, note_draw_rect: Rect2, source_rect: Rect2, quant_color: Color, preview: bool) -> void:
	if preview:
		target.draw_texture_rect_region(NOTES, note_draw_rect, source_rect, quant_color)
	else:
		target.draw_texture_rect_region(NOTECOLOR, note_draw_rect, source_rect, quant_color)
		target.draw_texture_rect_region(NOTES, note_draw_rect, source_rect)

func _draw():
	if strumline_object.strumline == null: return
	
	var note_size := ChartEditor.inst.settings.NOTE_SIZE
	custom_minimum_size.x = strumline_object.strumline.receptors.size() * note_size
	var note_draw_rect := Rect2(Vector2.ZERO, Vector2.ONE * note_size)
	
	for dir in strumline_object.strumline.receptors.size():
		var receptor := strumline_object.strumline.receptors[dir]
		var receptor_position := Vector2(dir * note_size, receptor_y_pos - note_size / 2.0)
		draw_set_transform(receptor_position)
		draw_texture_rect_region(NOTES, note_draw_rect, get_note_source_rect(dir, 0))
		
		for note in receptor.notes:
			draw_note(self, dir, note.time, note.length)
	
	draw_set_transform(Vector2.ZERO)
