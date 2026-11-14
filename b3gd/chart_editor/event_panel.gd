extends PanelContainer

@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")
@onready var event_container = %EventContainer
@onready var field_container = %EventFieldContainer
@onready var event_header = %EventHeader
@onready var event_id_box = %EventID

@onready var action_player = get_tree().get_first_node_in_group("ChartEditor").get_node("%ActionPlayer")

var event_id = -1:
	set(value):
		event_id = value

func update_event_data_view(_event_node: Variant, new_event_id: int, _show_event_data: bool) -> void:
	if event_id == new_event_id:
		field_container.update_event_values(event_id)
		return
	
	event_id = new_event_id
	
	if event_id == -1:
		hide()
		return
	else:
		show()
	
	var event = chart_source.chart.events[event_id]
	event_header.text = event.get_script().get_global_name()
	event_id_box.text = str(event_id)
	
	field_container.update_event_info(event_id)

func value_changed(property_name: String, member: int, new_value: Variant) -> void:
	var new_event = chart_source.chart.events[event_id].duplicate(true)
	
	if member != -1:
		var new_vector = new_event.get(property_name)
		new_vector[member] = new_value
		new_value = new_vector
	new_event.set(property_name, new_value)
	action_player.do_action({
		"type": action_player.ActionType.REPLACE_EVENT_DATA,
		"event": chart_source.chart.events[event_id], 
		"new_event": new_event
	})

func remove_event() -> void:
	var old_event_id = event_id
	event_container.event_selected = [null, -1, false]
	action_player.do_action({
		"type": action_player.ActionType.REMOVE_EVENT,
		"event": chart_source.chart.events[old_event_id], 
	})
