extends HBoxContainer

@onready var undo_button = $UndoButton
@onready var redo_button = $RedoButton


func _process(_delta):
	undo_button.disabled = !ChartEditor.undo_redo.has_undo()
	redo_button.disabled = !ChartEditor.undo_redo.has_redo()

func _on_undo_button_pressed():
	ChartEditor.undo_redo.undo()

func _on_redo_button_pressed():
	ChartEditor.undo_redo.redo()
