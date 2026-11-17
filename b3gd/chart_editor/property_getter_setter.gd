extends Node
class_name PropertyGetterSetter

@export var node: Node
@export_multiline("monospace", "no_wrap") var property_path: String

const TIMER_RESET = 5

var debounce: int = 0

func _process(_delta):
	if debounce > 0:
		debounce -= 1
		return
	
	var result = node.get_indexed(property_path)
	
	if get_outgoing_value() != result && can_set_incoming_value():
		debounce = TIMER_RESET
		set_incoming_value(result)

func send_outgoing_value(value: Variant):
	if debounce > 0:
		return
	
	debounce = TIMER_RESET
	
	var result = node.get_indexed(property_path)
	ChartEditor.undo_redo.create_action("Edit Property: %s:%s" % [node.name, property_path])
	
	# doesnt work for some reason #bruh
	#ChartEditor.undo_redo.add_do_property(node, property_path, value)
	#ChartEditor.undo_redo.add_undo_property(node, property_path, result)
	
	ChartEditor.undo_redo.add_do_method(func():
		node.set_indexed(property_path, value)
		set_incoming_value(value)
	)
	
	ChartEditor.undo_redo.add_undo_method(func():
		node.set_indexed(property_path, result)
		set_incoming_value(result)
	)
	
	ChartEditor.undo_redo.commit_action()
	

@warning_ignore("unused_parameter")
func set_incoming_value(value: Variant):
	return

func get_outgoing_value() -> Variant:
	return null

func can_set_incoming_value() -> bool:
	return true
