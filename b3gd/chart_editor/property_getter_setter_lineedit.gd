extends PropertyGetterSetter
class_name PropertyGetterSetterLineEdit

func _ready():
	var parent: LineEdit = get_parent()
	
	parent.text_submitted.connect(func(text):
		send_outgoing_value(text)
	)

func set_incoming_value(value: Variant):
	var parent: LineEdit = get_parent()
	
	parent.text = str(value)

func get_outgoing_value() -> Variant:
	var parent: LineEdit = get_parent()
	return parent.text

func can_set_incoming_value() -> bool:
	var parent: LineEdit = get_parent()
	return !parent.is_editing()
