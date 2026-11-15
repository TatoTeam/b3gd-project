extends Control

@export var event_scene: PackedScene
@export var event_list:Node2D
var chart_source = null

@warning_ignore("unused_signal")
signal make_event(event: Event)
@warning_ignore("unused_signal")
signal move_event(event: Event)
signal update_event_data_view(event_node, event_id:int, show_event_data:bool)

var loaded_icons = {}

var event_selected = [null, -1, false]:
	set(value):
		event_selected = value
		update_event_data_view.emit(event_selected[0], event_selected[1], event_selected[2])

func update_events():
	var child_id = 0
	for event in chart_source.chart.events:
		var event_y = event.time
		var event_lane = event.lane
		var event_instance = null
		
		if child_id < event_list.get_children().size():
			event_instance = event_list.get_children()[child_id]
		else:
			event_instance = event_scene.instantiate()
			event_list.add_child(event_instance)
			event_instance.event_box_toggled.connect(event_box_toggled)
		
		event_instance.position.y = event_y * 64
		event_instance.position.x = event_lane * -64
		event_instance.event_id = child_id
		event_instance.z_index = -event_lane
		
		var path = event.get_script().resource_path
		var icon_path = path.substr(0, path.length() - 3) + ".png"
		if loaded_icons.has(icon_path):
			event_instance.get_node("Button").icon = loaded_icons[icon_path]
		elif FileAccess.file_exists(icon_path):
			loaded_icons[icon_path] = load(icon_path)
			event_instance.get_node("Button").icon = loaded_icons[icon_path]
		
		child_id += 1
	
	for child in event_list.get_children().slice(child_id):
		child.queue_free()

func event_box_toggled(node: Node2D, event_id: int, toggled_on: bool):
	var possible_new_array = [node, event_id, toggled_on]
	if event_selected[0] == node and !toggled_on:
		event_selected = [null, -1, false]
	else:
		if event_selected[0] != null:
			event_selected[0].get_node("Button").button_pressed = false
		event_selected = possible_new_array
	
	print(event_selected)
