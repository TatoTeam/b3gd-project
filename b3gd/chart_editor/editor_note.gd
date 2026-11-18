extends Control
class_name EditorNote

const NOTES: CompressedTexture2D = preload("uid://bdkks2vfqiwwd")
const QUANT_LIST := [4, 8, 12, 16, 24, 32, 48, 64]

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

var note: Note
var receptor: Receptor
var note_placer: ColorRect
var direction: int
var _visual_state: Array = []

@onready var head: TextureRect = $Note
@onready var head_color: TextureRect = $Note/Color
@onready var hold: TextureRect = $Hold
@onready var hold_color: TextureRect = $Hold/Color

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

func _ready() -> void:
	for rect: TextureRect in [head, head_color, hold, hold_color]:
		rect.texture = rect.texture.duplicate()
	
	ChartEditor.instance.selection_updated.connect(func():
		queue_redraw()
	)
	queue_redraw()

func _draw():
	if !ChartEditor.selection.has(note): return
	
	var rect = Rect2(head.position, head.size)
	if hold.visible:
		rect = rect.merge(Rect2(hold.position, hold.size))
	
	draw_rect(rect, Color.WHITE, false, 2.0)

func update_visuals(columns: int, pixels_per_second: float, timing_revision: int, preview: bool = false) -> void:
	var state := [direction, columns, note.time, note.length, pixels_per_second, timing_revision, preview]
	if state == _visual_state:
		return

	_visual_state = state

	var note_size := ChartEditor.instance.settings.NOTE_SIZE
	var textures := get_note_vector_array(columns)
	var column: int = textures[direction % textures.size()]
	var head_region := Rect2(column * note_size, note_size, note_size, note_size)
	var hold_region := Rect2(column * note_size, note_size * 2, note_size, note_size)

	(head.texture as AtlasTexture).region = head_region
	(head_color.texture as AtlasTexture).region = head_region
	(hold.texture as AtlasTexture).region = hold_region
	(hold_color.texture as AtlasTexture).region = hold_region

	var color: Color = QUANT_COLORS[get_quant_id(note.time)]
	head_color.modulate = color
	hold_color.modulate = color
	head_color.visible = not preview
	hold_color.visible = not preview

	color.a = 0.75 if preview else 1.0
	head.modulate = color if preview else Color.WHITE
	hold.modulate = color if preview else Color.WHITE

	hold.visible = note.length > 0.0
	hold.size = Vector2(note_size, maxf(0.0, note.length * pixels_per_second))
	hold_color.size = hold.size
	queue_redraw()

# THIS IS SO GAYY
func _on_note_gui_input(event):
	if !note: return
	
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT && event.shift_pressed:
			if ChartEditor.selection.has(note):
				ChartEditor.remove_from_selection(note)
			else:
				ChartEditor.add_to_selection(note)
			accept_event()
		elif event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			remove_note()
			accept_event()

func remove_note():
	if !receptor.notes.has(note): return
	
	note_placer.remove_note(direction, note.time)
