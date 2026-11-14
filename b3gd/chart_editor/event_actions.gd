extends Node

@onready var chart_source:Node = get_tree().get_first_node_in_group("ChartSource")

signal event_list_shifted(at_index: int, by: int)

func add(event: Event):
	print(event)
	chart_source.chart.events.append(event)
	
	chart_source.chart.events.sort_custom(sort_ascending)
	event_list_shifted.emit(chart_source.chart.events.find(event), 1)
	get_parent().events_changed.emit()

func remove(event: Event):
	var index = chart_source.chart.events.find(event)
	print(index)
	chart_source.chart.events.erase(event)
	
	chart_source.chart.events.sort_custom(sort_ascending)
	event_list_shifted.emit(index, -1)
	get_parent().events_changed.emit()

func move(event: Event, new_time: float):
	var event_id = chart_source.chart.events.find(event)
	chart_source.chart.events[event_id].time = new_time
	chart_source.chart.events.sort_custom(sort_ascending)
	get_parent().events_changed.emit()

func replace(event: Event, new_event: Event):
	var event_id = chart_source.chart.events.find(event)
	chart_source.chart.events[event_id] = new_event
	chart_source.chart.events.sort_custom(sort_ascending)
	get_parent().events_changed.emit()

func sort_ascending(a, b):
	if is_equal_approx(a.time, b.time) and a is Event:
		return a.lane < b.lane
	return a.time < b.time
