extends Node2D

@export var strum_line_container: Node
@export var event_holder: Node 

@onready var selection_panel = $SelectionPanel

var selection_start: Vector2
var selection_end: Vector2
var selection_rect: Rect2

var selecting: bool = false

func _ready():
	EditorChartScrubber.inst.scrubbed.connect(func():
		# ig bro
		await get_tree().process_frame
		await get_tree().process_frame
		update_selection_end()
	)

func _input(event):
	if event is InputEventMouseMotion:
		if selecting:
			update_selection_end()
	
	if event is not InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	if event.pressed:
		if Input.is_key_pressed(KEY_SHIFT) and !selecting:
			selection_start = Vector2(event.global_position.x, y_to_sec(event.global_position.y))
			
			update_selection_end()
			_start_selecting()
	elif selecting:
		print("pls ")
		_stop_selecting()

func update_selection_end():
	selection_end = Vector2(get_global_mouse_position().x, y_to_sec(get_global_mouse_position().y))
	_update_selection_position()

func y_to_sec(y_pos: float) -> float:
	var y_size = get_parent().get_viewport_rect().size.y
	var offset_ratio := EditorStrumLine.TIMELINE_PRESENT_POINT
	
	var starting_offset_px = -(y_size * offset_ratio) 
	var starting_offset_sec = (starting_offset_px / EditorStrumLineEditor.inst.zoom / 64.0)
	
	var start_sec = EditorStrumLineEditor.inst.song_progress_seconds + starting_offset_sec
	
	return start_sec + (y_pos / EditorStrumLineEditor.inst.zoom / 64.0)

func sec_to_y(sec: float) -> float:
	var y_size = get_parent().get_viewport_rect().size.y
	var offset_ratio := EditorStrumLine.TIMELINE_PRESENT_POINT
	
	var starting_offset_px = -(y_size * offset_ratio) 
	var starting_offset_sec = (starting_offset_px / EditorStrumLineEditor.inst.zoom / 64.0)
	
	return (sec - EditorStrumLineEditor.inst.song_progress_seconds - starting_offset_sec) * EditorStrumLineEditor.inst.zoom * 64

func _update_selection_position():
	var start := Vector2(selection_start.x, sec_to_y(selection_start.y))
	var end := Vector2(selection_end.x, sec_to_y(selection_end.y))
	
	if end.x < start.x:
		var og_end := end.x
		end.x = start.x
		start.x = og_end
	
	if end.y < start.y:
		var og_end := end.y
		end.y = start.y
		start.y = og_end
	
	selection_rect = Rect2(start, end - start).abs()
	
	selection_panel.position = start
	selection_panel.size = end - start 

func _start_selecting():
	selecting = true
	selection_panel.visible = true

func _stop_selecting():
	selecting = false
	selection_panel.visible = false
	var selected_strum_lines: Array[Control] = []
	
	print("1:  ",selection_rect)
	for child in strum_line_container.get_children():
		print("2:  ",child.get_global_rect())
		print("3: ", selection_rect.intersection(child.get_global_rect()))
		if selection_rect.intersects(child.get_global_rect()):
			selected_strum_lines.append(child)
	print("yo:", selected_strum_lines)
