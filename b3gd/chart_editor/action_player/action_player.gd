extends Node

@export_group("Node References")
@onready var chart_source:Node = get_tree().get_first_node_in_group("ChartSource")
@onready var chart_loader:Node = get_tree().get_first_node_in_group("ChartLoader")
@onready var song_audio_player:AudioStreamPlayer = get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var note_manager:Node = get_tree().get_first_node_in_group("NoteManager")
@onready var data_saver:Node = get_parent().get_node("DataSaver")

@onready var note_actions = $NoteActions
@onready var event_actions = $EventActions
@onready var strum_line_actions = $StrumLineActions
@onready var song_data_actions = $SongDataActions

# called from else where
@warning_ignore("unused_signal")
signal notes_changed
@warning_ignore("unused_signal")
signal events_changed
@warning_ignore("unused_signal")
signal strum_line_changed(idx:int)
@warning_ignore("unused_signal")
signal strum_lines_changed
@warning_ignore("unused_signal")
signal song_data_changed

enum ActionType {
	GROUP,
	ADD_NOTE,
	REMOVE_NOTE,
	MOVE_NOTE,
	REPLACE_NOTE_DATA,
	
	ADD_EVENT,
	REMOVE_EVENT,
	MOVE_EVENT,
	REPLACE_EVENT_DATA,
	
	ADD_RECEPTOR,
	REMOVE_RECEPTOR,
	SET_STRUMLINE_CPU,
	
	SET_SONG_NAME,
	SET_SCROLL_SPEED,
}

func do_action(action: Dictionary, add_to_history: bool = true):
	if add_to_history:
		data_saver.update_history(action)
	match action.type:
		ActionType.GROUP:
			for sub_action in action.actions:
				do_action(sub_action)
		ActionType.ADD_NOTE: 
			note_actions.add(action.strum_line, action.receptor, action.note)
		ActionType.REMOVE_NOTE: 
			note_actions.remove(action.strum_line, action.receptor, action.note)
		ActionType.MOVE_NOTE: 
			note_actions.move(action.strum_line, action.receptor, action.note, action.new_time)
		ActionType.REPLACE_NOTE_DATA: 
			note_actions.replace(action.strum_line, action.receptor, action.note, action.new_note)
		
		ActionType.ADD_EVENT: 
			event_actions.add(action.event)
		ActionType.REMOVE_EVENT: 
			event_actions.remove(action.event)
		ActionType.MOVE_EVENT: 
			event_actions.move(action.event, action.new_time)
		ActionType.REPLACE_EVENT_DATA: 
			event_actions.replace(action.event, action.new_event)
		
		ActionType.ADD_RECEPTOR:
			strum_line_actions.add_receptor(action.index)
		ActionType.REMOVE_RECEPTOR:
			strum_line_actions.remove_receptor(action.index)
		ActionType.SET_STRUMLINE_CPU:
			strum_line_actions.set_cpu(action.index, action.cpu)
		
		ActionType.SET_SONG_NAME:
			song_data_actions.edit_song_name(action.old, action.new)
		ActionType.SET_SCROLL_SPEED:
			song_data_actions.edit_scroll_speed(action.old, action.new)

func undo_action(action: Dictionary):
	match action.type:
		ActionType.GROUP:
			for sub_action in action.actions.reverse():
				undo_action(sub_action)
		
		ActionType.ADD_NOTE: 
			note_actions.remove(action.strum_line, action.receptor, action.note)
		ActionType.REMOVE_NOTE: 
			note_actions.add(action.strum_line, action.receptor, action.note)
		ActionType.REPLACE_NOTE_DATA: 
			note_actions.replace(action.strum_line, action.receptor, action.new_note, action.note)
		
		ActionType.ADD_EVENT: 
			event_actions.remove(action.event)
		ActionType.REMOVE_EVENT: 
			event_actions.add(action.event)
		ActionType.REPLACE_EVENT_DATA: 
			event_actions.replace(action.new_event, action.event)
		
		ActionType.ADD_RECEPTOR:
			strum_line_actions.remove_receptor(action.index)
		ActionType.REMOVE_RECEPTOR:
			strum_line_actions.add_receptor(action.index)
		
		ActionType.SET_SONG_NAME:
			song_data_actions.edit_song_name(action.new, action.old)
		ActionType.SET_SCROLL_SPEED:
			song_data_actions.edit_scroll_speed(action.new, action.old)
		
		# These take special logic to make sure things are done in reverse.
		ActionType.MOVE_NOTE:
			var action_note = action.note.duplicate_deep()
			action_note.time = action.new_time
			note_actions.move(action.strum_line, action.receptor, action_note, action.note.time)
		ActionType.MOVE_EVENT:
			var action_event = action.event.duplicate_deep()
			action_event.time = action.new_time
			event_actions.move(action_event, action.event)
