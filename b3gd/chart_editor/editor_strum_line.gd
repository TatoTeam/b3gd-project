extends VBoxContainer
class_name EditorStrumLine

@onready var strum_line_drawer = $StrumLineDrawer

var strumline: StrumLine

var muted: bool = false:
	set(value):
		muted = value
		
		var vocal_layer = ChartLoader.inst.vocal_layers[ChartEditor.inst.chart.strum_lines.find(strumline)]
		ChartEditor.song_audio_player.stream.set_sync_stream_volume(vocal_layer, -50 if muted else 0)

func load_strumline(p_strumline: StrumLine):
	strumline = p_strumline
