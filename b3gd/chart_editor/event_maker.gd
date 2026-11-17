extends Control

@onready var class_box = $ClassBox
@onready var strum_line_container: HBoxContainer = $"../../../StrumLineContainer"

var event_time: float = 0.0
var lane: int = 0

func _process(_delta):
	if ChartEditor.song_audio_player == null: return
	if strum_line_container.get_child_count() == 0: return
	
	var strumline: EditorStrumLine = strum_line_container.get_child(0)
	var drawer: EditorStrumlineDrawer = strumline.strum_line_drawer
	
	if !class_box.button_pressed:
		event_time = drawer.y_to_snapped_time(drawer.get_local_mouse_position().y)
	
	global_position.y = (drawer.get_global_transform() * Vector2(0.0, drawer.time_to_y(event_time))).y
	
	lane = 0
	for event in ChartEditor.instance.chart.events:
		if abs(event.time - event_time) < 0.05:
			if event.lane >= lane:
				lane = event.lane + 1
	
	position.x = (-(lane) * (EditorEventDrawer.BUTTON_SIZE.x + 15)) - EditorEventDrawer.BUTTON_SIZE.x

func _on_class_box_item_selected(index):
	class_box.select(-1)
	
	var event: Event = load(class_box.class_paths[index]).new()
	event.time = event_time
	event.lane = lane
	
	ChartEditor.instance.chart.events.append(event)
