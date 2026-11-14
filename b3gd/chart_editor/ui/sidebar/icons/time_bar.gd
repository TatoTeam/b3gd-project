extends HBoxContainer

@onready var format_box = $TimeFormatBox
@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")

@onready var current_time = $CurrentTimeLabel
@onready var total_time = $TotalTimeLabel

func _ready() -> void:
	if song_audio_player == null:
		printerr("SongAudioPlayer Does not exist: Time Bar disabled")
		process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	var time = song_audio_player.song_progress_seconds
	var total = song_audio_player.stream.get_length()
	if format_box.selected == 1:
		time = song_audio_player.song_progress_beats
		total = song_audio_player.get_beat_from_seconds(total)
	
	var has_hours = total >= 3600.0 and format_box.selected == 1
	var has_minutes = format_box.selected != 1
	
	current_time.text = format_time("", time, has_minutes, has_hours)
	total_time.text = format_time("/ ", total, has_minutes, has_hours)

func format_time(string: String, seconds: float, has_minutes: bool, has_hours: bool = false) -> String:
	if seconds < 0:
		seconds *= -1
		string += "-"
	
	var subdivisions: Array[Dictionary] = [
		{"divide": 1, "post": ".", "pad": 2}, 
		{"divide": 0.01, "post": "", "pad": 2}
	]
	if has_minutes: 
		subdivisions.insert(0, {"divide": 60.0, "post":":", "pad":2})
	if has_hours: 
		subdivisions.insert(0, {"divide": 3600.0, "post":":", "pad":0})
	
	for subdivision in subdivisions:
		var subdivided_value = int(seconds / subdivision.divide)
		string += str(subdivided_value).pad_zeros(subdivision.pad)
		seconds -= subdivided_value * subdivision.divide
		string += subdivision.post
	
	return string
