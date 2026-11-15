extends Node2D

@onready var selection_panel = $SelectionPanel

var selection_start: Vector2
var selection_end: Vector2

var selecting: bool = false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if selecting:
			selection_end = Vector2(0, y_to_sec(event.global_position.y))
			_update_selection_position()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && Input.is_key_pressed(KEY_SHIFT):
			if event.pressed:
				selection_start = Vector2(0, y_to_sec(event.global_position.y))
				selection_end = selection_start
				
				_update_selection_position()
				_start_selecting()
			else:
				selection_end = Vector2(0, y_to_sec(event.global_position.y))
				_update_selection_position()
				_stop_selecting()

func y_to_sec(y_pos: float) -> float:
	var y_size = get_parent().get_viewport_rect().size.y
	var offset_ratio := EditorStrumLine.TIMELINE_PRESENT_POINT
	
	var starting_offset_px = -(y_size * offset_ratio) 
	var starting_offset_sec = (starting_offset_px / EditorStrumLineEditor.inst.zoom / 64.0)
	
	var start_sec = EditorStrumLineEditor.inst.song_progress_seconds + starting_offset_sec
	
	return start_sec + (y_pos / EditorStrumLineEditor.inst.zoom / 64.0)

func _update_selection_position():
	var start := selection_start
	var end := selection_end
	
	if end.x < start.x:
		var og_end := end.x
		end.x = start.x
		start.x = og_end
	
	if end.y < start.y:
		var og_end := end.y
		end.y = start.y
		start.y = og_end
	
	selection_panel.global_position = start
	selection_panel.size = end - start 

func _start_selecting():
	selecting = true
	selection_panel.visible = true

func _stop_selecting():
	selecting = false
	selection_panel.visible = false
