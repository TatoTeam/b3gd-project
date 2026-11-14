extends Node

@onready var event_parent = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%EventContainer")
@onready var event_maker = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%EventMaker")

@onready var chart_source:Node = get_tree().get_first_node_in_group("ChartSource")

func _ready() -> void:
	event_parent.chart_source = chart_source
	event_parent.update_events()


func event_list_shifted(at_index: int, by: int) -> void:
	if at_index == -1:
		return
	if by == -1 and event_parent.event_selected[1] == at_index:
		event_parent.event_selected = [null, -1, false]
	if event_parent.event_selected[1] >= at_index:
		event_parent.event_selected = [null, event_parent.event_selected[1] + by, false]

func _on_action_player_events_changed() -> void:
	event_parent.event_selected = event_parent.event_selected.duplicate()
	event_parent.update_events()
