extends Node

@onready var chart_source:Node = get_tree().get_first_node_in_group("ChartSource")

func edit_song_name(_old_name, new_name):
	chart_source.chart.metadata.name = new_name
	get_parent().song_data_changed.emit()

func edit_scroll_speed(_old_speed, new_speed):
	chart_source.chart.scroll_speed = new_speed
	get_parent().song_data_changed.emit()
