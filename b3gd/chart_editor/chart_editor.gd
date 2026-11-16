extends MarginContainer
class_name ChartEditor

static var inst: ChartEditor
static var undo_redo: UndoRedo:
	get():
		return inst._undo_redo

static var song_audio_player: SongAudioPlayer:
	get():
		return inst._song_audio_player

@export var chart: Chart
@export var settings: ChartEditorSettings

var _song_audio_player: SongAudioPlayer

var _undo_redo: UndoRedo

func _init():
	inst = self
	
	_undo_redo = UndoRedo.new()

func _ready():
	song_audio_player.pause()
