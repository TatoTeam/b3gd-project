extends Control

const NOTES: CompressedTexture2D = preload("uid://bdkks2vfqiwwd")

@onready var strumline_object: EditorStrumLine = $"../.."

var mouse_inside: bool = false

func _ready():
	mouse_entered.connect(func():
		mouse_inside = true
	)
	
	mouse_exited.connect(func():
		mouse_inside = false
	)

func _process(_delta):
	# honestly no reason not to do this here since notes will be usually redrawn every frame due to the song yknow.. playing
	queue_redraw()

func _draw():
	if strumline_object.strumline == null: return
	if !mouse_inside: return
	
	var note_texture_array := EditorStrumlineDrawer.get_note_vector_array(strumline_object.strumline.receptors.size())
	
	var step := get_rect().size.x / (strumline_object.strumline.receptors.size())
	var dir := floori(get_local_mouse_position().x / step)
	
	var note_size_vec := Vector2.ONE * ChartEditor.inst.settings.NOTE_SIZE
	var note_time = ChartEditor.song_audio_player.song_progress_seconds + (get_local_mouse_position().y / ChartEditor.inst.settings.NOTE_SIZE / ChartEditor.inst.settings.editor_zoom)
	
	var beat = ChartEditor.song_audio_player.get_beat_from_seconds(note_time)
	beat = snapped(beat, 4.0 / ChartEditor.inst.settings.snapping)
	note_time = ChartEditor.song_audio_player.get_seconds_from_beat(beat)
	
	var quant_color: Color = EditorStrumlineDrawer.QUANT_COLORS[EditorStrumlineDrawer.get_quant_id(note_time)]
	quant_color.a = 0.75
	
	var note_offset: float = note_time - ChartEditor.song_audio_player.song_progress_seconds
	
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
	
	draw_texture_rect_region(NOTES, note_draw_rect, src_rect, quant_color)
	
	#if note.length > 0.0:
	#	draw_set_transform(note_draw_pos + Vector2(0, ChartEditor.inst.settings.NOTE_SIZE / 2.0), 0.0, Vector2.ONE)
	#	src_rect.position.y = ChartEditor.inst.settings.NOTE_SIZE * 2
	#	
	#	note_draw_rect.size.y = note.length * ChartEditor.inst.settings.NOTE_SIZE * ChartEditor.inst.settings.editor_zoom
	#	
	#	draw_texture_rect_region(NOTES, note_draw_rect, src_rect)
			
