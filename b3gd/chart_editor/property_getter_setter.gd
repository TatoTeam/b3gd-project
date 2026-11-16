extends Node
class_name PropertyGetterSetter

@export var node: Node
@export_multiline("monospace", "no_wrap") var property_path: String

func _process(_delta):
	var result = node.get_indexed(property_path)
	
	if get_outgoing_value() != result:
		if can_set_incoming_value():
			set_incoming_value(result)
		elif get_outgoing_value() != null:
			node.set_indexed(property_path, get_outgoing_value())

@warning_ignore("unused_parameter")
func set_incoming_value(value: Variant):
	return

func get_outgoing_value() -> Variant:
	return null

func can_set_incoming_value() -> bool:
	return true
