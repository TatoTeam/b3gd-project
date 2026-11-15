extends Node
class_name EditorSelectionActions

static var selection: Array[EditorSelectable] = []


## Do not call directly! Use ActionPlayer
static func _select(selectable: EditorSelectable):
	if selection.has(selectable): return
	
	selection.append(selectable)
	
	print(selection)

## Do not call directly! Use ActionPlayer
static func _deselect(selectable: EditorSelectable):
	if !selection.has(selectable): return
	
	selection.remove_at(selection.find(selectable))
	
	print(selection)

func _enter_tree():
	selection = []

func _exit_tree():
	selection = []
