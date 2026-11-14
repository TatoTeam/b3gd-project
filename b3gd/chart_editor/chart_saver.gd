extends Node

var action_history = []
var current_action = 0:
	set(value):
		current_action = value
		
		undo_button.disabled = current_action >= action_history.size()
		redo_button.disabled = current_action == 0

@onready var save_button: Button = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%SaveButton")
@onready var undo_button: Button = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%UndoButton")
@onready var redo_button: Button = get_tree().get_first_node_in_group("ChartEditorUI").get_node("%RedoButton")
@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")
@onready var action_player = %ActionPlayer


func _ready() -> void:
	save_button.pressed.connect(save)
	undo_button.pressed.connect(undo)
	redo_button.pressed.connect(redo)
	current_action = 0

func undo() -> void:
	if current_action >= action_history.size():
		return
	
	var action = action_history[current_action]
	print(action.type, ", ", action_player.ActionType.keys()[action.type])
	action_player.undo_action(action)
	current_action += 1

func redo() -> void:
	if current_action == 0:
		return
	
	current_action -= 1
	var action = action_history[current_action]
	print(action.type, ", ", action_player.ActionType.keys()[action.type])
	action_player.do_action(action, false)

func update_history(new_action: Dictionary):
	if current_action != 0:
		action_history = action_history.slice(current_action)
		current_action = 0
	action_history.insert(0, new_action)
	undo_button.disabled = false

func save() -> void:
	DirAccess.rename_absolute(chart_source.chart.resource_path, chart_source.chart.resource_path + "_old")
	ResourceSaver.save(chart_source.chart, chart_source.chart.resource_path)

func autosave() -> void:
	var autosave_path = "res://.backups/" + chart_source.chart.resource_path.replace("res://", "")
	DirAccess.make_dir_recursive_absolute(autosave_path.substr(0, autosave_path.rfind("/")))
	if FileAccess.file_exists(autosave_path):
		DirAccess.rename_absolute(autosave_path, autosave_path + "_old")
	ResourceSaver.save(chart_source.chart, autosave_path)
