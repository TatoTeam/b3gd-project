extends PropertyGetterSetter
class_name PropertyGetterSetterSpinBox

var mouse_inside := false

func _ready():
	var parent: SpinBox = get_parent()
	
	parent.mouse_entered.connect(func():
		mouse_inside = true
	)
	
	parent.mouse_entered.connect(func():
		mouse_inside = false
	)

func set_incoming_value(value: Variant):
	var parent: SpinBox = get_parent()
	
	parent.value = float(value)

func get_outgoing_value() -> Variant:
	var parent: SpinBox = get_parent()
	return parent.value

func can_set_incoming_value() -> bool:
	return false
