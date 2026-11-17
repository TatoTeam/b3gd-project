extends Control
class_name EditorStrumlineDrawer

const NOTES: CompressedTexture2D = preload("uid://bdkks2vfqiwwd")
const NOTECOLOR: CompressedTexture2D = preload("uid://p6quxyfjutej")
const QUANT_LIST := [4, 8, 12, 16, 24, 32, 48, 64]

@onready var strumline_object: EditorStrumLine = $".."

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


func _draw():
	if strumline_object.strumline == null: return
	
	custom_minimum_size.x = strumline_object.strumline.receptors.size() * ChartEditor.inst.settings.NOTE_SIZE
	
	var note_texture_array := get_note_vector_array(strumline_object.strumline.receptors.size())
	
	for dir in range(strumline_object.strumline.receptors.size()):
		
		var receptor := strumline_object.strumline.receptors[dir]
		for note in receptor.notes:
			var note_size_vec := Vector2.ONE * ChartEditor.inst.settings.NOTE_SIZE
			var note_offset: float = note.time - ChartEditor.song_audio_player.song_progress_seconds
			
			var quant_color: Color = QUANT_COLORS[get_quant_id(note.time)]
			
			var sprite_x_pos: int = note_texture_array[dir % note_texture_array.size()] * ChartEditor.inst.settings.NOTE_SIZE
			
			var note_draw_pos := Vector2(
				(dir * ChartEditor.inst.settings.NOTE_SIZE),
				(note_offset * ChartEditor.inst.settings.NOTE_SIZE * ChartEditor.inst.settings.editor_zoom) - ChartEditor.inst.settings.NOTE_SIZE / 2.0
			)
			
			draw_set_transform(note_draw_pos, 0.0, Vector2.ONE)
			
			var note_draw_rect := Rect2(Vector2.ZERO, note_size_vec)
			var src_rect := Rect2(
				Vector2(sprite_x_pos, ChartEditor.inst.settings.NOTE_SIZE * 1), 
				note_size_vec
			)
			
			draw_texture_rect_region(NOTECOLOR, note_draw_rect, src_rect, quant_color)
			draw_texture_rect_region(NOTES, note_draw_rect, src_rect)
			
			if note.length > 0.0:
				draw_set_transform(note_draw_pos + Vector2(0, ChartEditor.inst.settings.NOTE_SIZE / 2.0), 0.0, Vector2.ONE)
				src_rect.position.y = ChartEditor.inst.settings.NOTE_SIZE * 2
				
				note_draw_rect.size.y = note.length * ChartEditor.inst.settings.NOTE_SIZE * ChartEditor.inst.settings.editor_zoom
				
				draw_texture_rect_region(NOTECOLOR, note_draw_rect, src_rect, quant_color)
				draw_texture_rect_region(NOTES, note_draw_rect, src_rect)
			
