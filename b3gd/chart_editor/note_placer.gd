extends Control

const NOTES: CompressedTexture2D = preload("uid://bdkks2vfqiwwd")

@onready var strumline_object: EditorStrumLine = $"../.."
@onready var strum_line_drawer = $".."

var mouse_inside: bool = false

var placing_note: bool = false

var note_time: float = 0.0
var note_length: float = 0.0

var note_dir: int = 0

func _ready():
	mouse_entered.connect(func():
		mouse_inside = true
	)
	
	mouse_exited.connect(func():
		mouse_inside = false
	)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if placing_note && event.pressed == false:
				add_note()
			
			placing_note = event.pressed
			accept_event()

func remove_note(receptor, time):
	if receptor > strumline_object.strumline.receptors.size() - 1 || receptor < 0: return
	
	var notes = strumline_object.strumline.receptors[receptor].notes
	for note in notes:
		if abs(note.time - time) < 0.05:
			notes.remove_at(notes.find(note)) # Only removes one at a time
			break

func add_note():
	if note_dir > strumline_object.strumline.receptors.size() - 1 || note_dir < 0: return
	
	remove_note(note_dir, note_time)
	
	var receptor: Receptor = strumline_object.strumline.receptors.get(note_dir)
	var new_note := Note.new()
	new_note.time = note_time
	new_note.length = note_length
	
	receptor.notes.append(new_note)

func _process(_delta):
	if strumline_object.strumline == null: return
	
	var receptor_offset_sec: float = strum_line_drawer.receptor_y_pos / ChartEditor.inst.settings.NOTE_SIZE / ChartEditor.inst.settings.editor_zoom
	
	if !placing_note:
		var step := get_rect().size.x / (strumline_object.strumline.receptors.size())
		note_dir = floori(get_local_mouse_position().x / step)
		note_time = ChartEditor.song_audio_player.song_progress_seconds + (get_local_mouse_position().y / ChartEditor.inst.settings.NOTE_SIZE / ChartEditor.inst.settings.editor_zoom)
		note_time -= receptor_offset_sec
		
		var beat = ChartEditor.song_audio_player.get_beat_from_seconds(note_time)
		beat = snapped(beat, 4.0 / ChartEditor.inst.settings.snapping)
		note_time = ChartEditor.song_audio_player.get_seconds_from_beat(beat)
		
		note_length = 0
	else:
		note_length = max(
			(ChartEditor.song_audio_player.song_progress_seconds + (get_local_mouse_position().y / ChartEditor.inst.settings.NOTE_SIZE / ChartEditor.inst.settings.editor_zoom)) - note_time,
			0
		)
		
		note_length -= receptor_offset_sec
		
		var beat = ChartEditor.song_audio_player.get_beat_from_seconds(note_length)
		beat = snapped(beat, 4.0 / ChartEditor.inst.settings.snapping)
		note_length = ChartEditor.song_audio_player.get_seconds_from_beat(beat)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) && !placing_note && mouse_inside:
		remove_note(note_dir, note_time)
	
	# honestly no reason not to do this here since notes will be usually redrawn every frame due to the song yknow.. playing
	queue_redraw()

func _draw():
	if strumline_object.strumline == null: return
	if !mouse_inside && !placing_note: return
	
	var note_texture_array := EditorStrumlineDrawer.get_note_vector_array(strumline_object.strumline.receptors.size())
	
	var note_size_vec := Vector2.ONE * ChartEditor.inst.settings.NOTE_SIZE
	
	var quant_color: Color = EditorStrumlineDrawer.QUANT_COLORS[EditorStrumlineDrawer.get_quant_id(note_time)]
	quant_color.a = 0.75
	
	var note_offset: float = note_time - ChartEditor.song_audio_player.song_progress_seconds
	
	var sprite_x_pos: int = note_texture_array[note_dir % note_texture_array.size()] * ChartEditor.inst.settings.NOTE_SIZE
	
	var note_draw_pos := Vector2(
		(note_dir * ChartEditor.inst.settings.NOTE_SIZE),
		(note_offset * ChartEditor.inst.settings.NOTE_SIZE * ChartEditor.inst.settings.editor_zoom) - ChartEditor.inst.settings.NOTE_SIZE / 2.0
	)
	
	note_draw_pos.y += strum_line_drawer.receptor_y_pos
	
	draw_set_transform(note_draw_pos, 0.0, Vector2.ONE)
	
	var note_draw_rect := Rect2(Vector2.ZERO, note_size_vec)
	var src_rect := Rect2(
		Vector2(sprite_x_pos, ChartEditor.inst.settings.NOTE_SIZE * 1), 
		note_size_vec
	)
	
	draw_texture_rect_region(NOTES, note_draw_rect, src_rect, quant_color)
	
	if note_length > 0.0:
		draw_set_transform(note_draw_pos + Vector2(0, ChartEditor.inst.settings.NOTE_SIZE / 2.0), 0.0, Vector2.ONE)
		src_rect.position.y = ChartEditor.inst.settings.NOTE_SIZE * 2
		
		note_draw_rect.size.y = note_length * ChartEditor.inst.settings.NOTE_SIZE * ChartEditor.inst.settings.editor_zoom
		
		draw_texture_rect_region(NOTES, note_draw_rect, src_rect, quant_color)
		
