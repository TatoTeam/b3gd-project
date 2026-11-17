extends Resource
class_name ChartEditorSettings

const NOTE_SIZE := 64

@export var editor_zoom: float = 4.0
@export var snapping: float = 8.0
@export var receptor_offset: float = 0.3

func snap_time(time: float) -> float:
	if ChartEditor.song_audio_player == null:
		return time
	
	var beat: float = ChartEditor.song_audio_player.get_beat_from_seconds(time)
	beat = snappedf(beat, 4.0 / ChartEditor.inst.settings.snapping)
	return ChartEditor.song_audio_player.get_seconds_from_beat(beat)
