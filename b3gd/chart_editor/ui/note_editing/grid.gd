extends Node2D

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var strum_line_rect = get_parent().get_parent()
@onready var snap = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%Snap")

func update():
	var current_grid_time = -4.0
	var grid_end = song_audio_player.stream.get_length()
	
	var snap_distance = 4.0 / float(snap.value)
	var bpm_changes = song_audio_player.bpm_events
	var current_bpm_change = 0
	var bpm_change_distance = song_audio_player.get_seconds_from_beat(current_grid_time + snap_distance)
	var last_time = song_audio_player.get_seconds_from_beat(current_grid_time)
	bpm_change_distance -= last_time
	
	var old_children = get_children().duplicate()
	var child_id = 0
	while true: 
		if current_bpm_change + 1 < bpm_changes.size() and bpm_changes[current_bpm_change + 1].time < last_time:
			last_time = song_audio_player.get_seconds_from_beat(current_grid_time)
			bpm_change_distance = song_audio_player.get_seconds_from_beat(current_grid_time + snap_distance)
			bpm_change_distance -= last_time
			current_bpm_change += 1
		
		var line_y = last_time
		last_time += bpm_change_distance
		var is_grid_end = line_y > grid_end
		if is_grid_end:
			line_y = grid_end
		line_y *= 64.0
		
		var alpha = 1.0
		var round_time_for_highlight = snapped(current_grid_time, 0.0001)
		if round(round_time_for_highlight * 8.0) == round_time_for_highlight * 8.0:
			alpha = [
				0.0, 0.95, 0.8, 0.95, 0.5, 0.95, 0.8, 0.95
			][int(floor(round_time_for_highlight * 8) - (floor(round_time_for_highlight) * 8))]
		alpha = lerp(0.4, 0.1, alpha)
		if is_grid_end:
			alpha = 1
		
		if current_grid_time < 0:
			alpha *= 0.5 + (current_grid_time / 8.0)
		
		var line2d = null
		if child_id < old_children.size():
			line2d = old_children[child_id]
		else:
			line2d = Line2D.new()
			add_child(line2d)
			line2d.add_point(Vector2(0, 0))
			line2d.add_point(Vector2(1.0, 0))
			line2d.width = 1.0
		
		child_id += 1
		
		line2d.modulate.a = alpha
		line2d.position.y = line_y
		
		current_grid_time += snap_distance
		
		if is_grid_end:
			break
	
	for child in get_children().slice(child_id):
		child.free()
