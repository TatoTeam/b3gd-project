extends Control

@onready var strumline_object: EditorStrumLine = $"../.."
@onready var strum_line_drawer: EditorStrumlineDrawer = $".."

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

func remove_note(receptor: int, time: float, create_new_action: bool = true):
	if receptor > strumline_object.strumline.receptors.size() - 1 || receptor < 0: return
	
	var notes = strumline_object.strumline.receptors[receptor].notes
	for note in notes:
		if abs(note.time - time) < 0.05:
			if create_new_action:
				ChartEditor.undo_redo.create_action("Remove Note")
			
			ChartEditor.undo_redo.add_do_reference(note)
			
			ChartEditor.undo_redo.add_do_method(func():
				notes.append(note)
			)
			
			ChartEditor.undo_redo.add_undo_method(func():
				notes.erase(note)
			)
			
			if create_new_action: ChartEditor.undo_redo.commit_action()
			
			break

func add_note():
	if note_dir > strumline_object.strumline.receptors.size() - 1 || note_dir < 0: return
	
	ChartEditor.undo_redo.create_action("Place Note")
	
	remove_note(note_dir, note_time, false)
	
	var receptor: Receptor = strumline_object.strumline.receptors.get(note_dir)
	
	var new_note := Note.new()
	new_note.time = note_time
	new_note.length = note_length
	
	ChartEditor.undo_redo.add_do_reference(new_note)
	ChartEditor.undo_redo.add_do_method(func():
		receptor.notes.append(new_note)
	)
	
	ChartEditor.undo_redo.add_undo_method(func():
		receptor.notes.erase(new_note)
	)
	
	ChartEditor.undo_redo.commit_action()
	

func _process(_delta):
	if strumline_object.strumline == null: return
	
	if strumline_object.strumline.receptors.is_empty(): return

	var mouse_position := get_local_mouse_position()
	var mouse_time := strum_line_drawer.y_to_time(mouse_position.y)
	if !placing_note:
		var step := size.x / strumline_object.strumline.receptors.size()
		note_dir = floori(mouse_position.x / step)
		note_time = ChartEditor.instance.settings.snap_time(mouse_time)
		note_length = 0.0
	else:
		note_length = maxf(ChartEditor.instance.settings.snap_time(maxf(mouse_time - note_time, 0.0)), 0.0)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) && !placing_note && mouse_inside:
		remove_note(note_dir, note_time)
	
	# honestly no reason not to do this here since notes will be usually redrawn every frame due to the song yknow.. playing
	queue_redraw()

func _draw():
	if strumline_object.strumline == null: return
	if !mouse_inside && !placing_note: return
	
	strum_line_drawer.draw_note(self, note_dir, note_time, note_length, true)
