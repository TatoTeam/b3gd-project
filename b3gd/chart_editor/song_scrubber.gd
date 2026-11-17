extends VScrollBar


func _unhandled_input(event):
	if event.is_action_pressed("editor_time_down") || event.is_action_pressed("editor_time_up"):
		var time := 4.0 / ChartEditor.instance.settings.snapping
		
		if event.is_action_pressed("editor_time_up"):
			time *= -1
		
		var seek_time := ChartEditor.instance.settings.snap_time(ChartEditor.song_audio_player.song_progress_seconds + time)
		ChartEditor.song_audio_player.track_seek(seek_time)
		value = ChartEditor.song_audio_player.song_progress_seconds
	
	if event.is_action_pressed("editor_pause"):
		if ChartEditor.song_audio_player.paused:
			ChartEditor.song_audio_player.unpause()
		else:
			ChartEditor.song_audio_player.pause()
			
