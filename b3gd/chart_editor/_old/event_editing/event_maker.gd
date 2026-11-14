extends Control

@onready var chart_data_modifier := %EditorChartDataModifier
@onready var event_maker := $EditorEventClassBox
@onready var strumline_container = %EditorStrumLineContainer

var time = 1
var lane = 1

var is_mouse_over = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		event_maker.disabled = false
		if !event_maker.is_hovered():
			event_maker.disabled = true
			event_maker.selected = -1

func _process(_delta: float) -> void:
	var mouse_position = get_parent().get_local_mouse_position()
	is_mouse_over = Rect2(Vector2.ZERO, get_parent().size).has_point(mouse_position)
	if get_parent().item_being_dragged:
		is_mouse_over = false
	
	if !event_maker.disabled:
		return
	
	if !is_mouse_over:
		hide()
		return
	else:
		show()
	
	var time_mouse_pos = mouse_position.y
	var size_percent = get_parent().size.y * strumline_container.timeline_present_point
	time_mouse_pos -= size_percent
	var scroll_mult = get_parent().scroll_zoom.value
	
	time_mouse_pos /= 64 * scroll_mult
	time_mouse_pos += get_parent().song_audio_player.song_progress_seconds
	time_mouse_pos = chart_data_modifier.get_snapped_time(time_mouse_pos)
	time = time_mouse_pos
	
	var max_lane_at_pos = -1
	for event in get_parent().chart_source.chart.events:
		if abs(event.time - time) < 0.05:
			max_lane_at_pos = max(max_lane_at_pos, event.lane)
	lane = max_lane_at_pos + 2


func _on_editor_event_class_box_item_selected(_index: int) -> void:
	chart_data_modifier.add_event(time)
	event_maker.disabled = true
	event_maker.selected = -1
