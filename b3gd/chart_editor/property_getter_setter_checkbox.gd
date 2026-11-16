extends PropertyGetterSetter
class_name PropertyGetterSetterCheckBox

var pressed_down: bool = false

func _ready():
	var parent: CheckBox = get_parent()
	
	parent.button_down.connect(func():
		pressed_down = true
	)
	
	parent.button_up.connect(func():
		pressed_down = false
	)

func set_incoming_value(value: Variant):
	var parent: CheckBox = get_parent()
	
	parent.button_pressed = bool(value)

func get_outgoing_value() -> Variant:
	var parent: CheckBox = get_parent()
	return parent.button_pressed

func can_set_incoming_value() -> bool:
	return pressed_down
