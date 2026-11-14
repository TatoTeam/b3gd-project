extends Node

@onready var song_name: LineEditNoFocus = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%SongName")
@onready var scroll_speed: SpinSlider = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%ScrollSpeed")
@onready var chart_source:Node = get_tree().get_first_node_in_group("ChartSource")

@onready var action_player = %ActionPlayer

func _ready() -> void:
	print(song_name)
	print(scroll_speed)
	scroll_speed.value_changed.connect(change_scroll_speed)
	song_name.text_changed.connect(change_song_name)
	update_values()

func update_values():
	scroll_speed.value_changed.disconnect(change_scroll_speed)
	song_name.text_changed.disconnect(change_song_name)
	scroll_speed.value = chart_source.chart.scroll_speed
	song_name.text = chart_source.chart.metadata.name
	scroll_speed.value_changed.connect(change_scroll_speed)
	song_name.text_changed.connect(change_song_name)

func change_scroll_speed(value):
	action_player.do_action({
		"type": action_player.ActionType.SET_SCROLL_SPEED,
		"old": chart_source.chart.scroll_speed,
		"new": value
	})

func change_song_name(value):
	action_player.do_action({
		"type": action_player.ActionType.SET_SONG_NAME,
		"old": chart_source.chart.metadata.name,
		"new": value
	})

func _on_action_player_song_data_changed() -> void:
	update_values()
