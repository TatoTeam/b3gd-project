extends PropertyGetterSetter
class_name PropertyGetterSetterSpinBox

func _ready():
	var parent: SpinBox = get_parent()
	
	parent.value_changed.connect(func(value):
		send_outgoing_value(value)
	)

func set_incoming_value(value: Variant):
	var parent: SpinBox = get_parent()
	
	parent.set_value_no_signal(value)

func get_outgoing_value() -> Variant:
	var parent: SpinBox = get_parent()
	return parent.value

func can_set_incoming_value() -> bool:
	return true
