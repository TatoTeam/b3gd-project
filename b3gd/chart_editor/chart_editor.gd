extends MarginContainer
class_name ChartEditor

static var instance: ChartEditor
static var undo_redo: UndoRedo:
	get():
		return instance._undo_redo

static var song_audio_player: SongAudioPlayer:
	get():
		return instance._song_audio_player

@export var chart: Chart
@export var settings: ChartEditorSettings

@onready var timeline: EditorTimeline = $UIContainer/WorkAreaScroll/Container/EventContainer/Timeline

var _song_audio_player: SongAudioPlayer

var _undo_redo: UndoRedo

func _init():
	instance = self
	
	_undo_redo = UndoRedo.new()

func _ready():
	song_audio_player.pause()
