extends VBoxContainer

@export var header_label_settings: LabelSettings
@export var property_label_settings: LabelSettings
@export var error_label_settings: LabelSettings

@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")

signal value_changed(property_name: String, member: int, new_value: Variant)

var event_param_info = {}

func update_event_values(event_id):
	for source in event_param_info.keys():
		if source == null:
			continue
		var event_params = event_param_info[source]
		var new_value = chart_source.chart.events[event_id].get(event_params.name)
		if event_params.member != -1:
			new_value = new_value[event_params.member]
		
		for i in event_params.change.get_connections():
			event_params.change.disconnect(i.callable)
		
		source.set(event_params.value, new_value)
		
		event_params.change.connect(box_value_changed.bind(source))

func update_event_info(event_id):
	for child in get_children():
		child.free()
	
	var event = chart_source.chart.events[event_id]
	
	for property in get_formatted_property_list(event.get_property_list()):
		var name_label = Label.new()
		name_label.text = property.name
		if property.is_category:
			name_label.label_settings = header_label_settings
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			add_child(name_label)
			continue
		
		name_label.text = name_label.text.capitalize() + ": "
		name_label.label_settings = property_label_settings
		
		var hbox = HBoxContainer.new()
		add_child(hbox)
		hbox.add_child(name_label)
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var property_value = event.get(property.name)
		var property_hints = get_property_hints(property.hint, property.hint_string)
		var property_boxes = get_property_boxes(property.type, property_hints.enum_values, property_hints.range_options)
		
		for property_box in property_boxes:
			if property_box.id != -1:
				property_box.ref.set(property_box.value, property_value[property_box.id])
			else:
				property_box.ref.set(property_box.value, property_value)
			property_box.change.connect(box_value_changed.bind(property_box.ref))
			property_box.ref.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			property_box.ref.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
			event_param_info.set(property_box.ref, {"name": property.name, "member": property_box.id, "value": property_box.value, "change": property_box.change})
			hbox.add_child(property_box.ref)

func format_property(property: Dictionary):
	if property.type == 0 and property.name.ends_with(".gd"):
		return {"is_category": true, "name": property.name}
	
	if property.name.contains("/") or !(property.usage & PROPERTY_USAGE_EDITOR):
		return null
	
	property["is_category"] = false
	return property

func get_formatted_property_list(property_list: Array[Dictionary]):
	var export_properties = []
	
	var current_script_source = ""
	for property in property_list:
		var formatted_property = format_property(property)
		if formatted_property == null:
			continue
		
		if formatted_property.is_category:
			current_script_source = formatted_property.name
		
		if current_script_source in ["", "event.gd"]:
			continue
		
		export_properties.append(formatted_property)
	return export_properties

func get_property_hints(hint_id, hint_string) -> Dictionary[String, Dictionary]:
	var enum_values = {}
	var range_options = {}
	var enum_string = hint_string.split(",")
	match hint_id:
		PROPERTY_HINT_RANGE:
			for i in range(min(enum_string.size(), 3)):
				range_options[["lower", "upper", "step"][i]] = float(enum_string[i])
			range_options.allow_lesser = enum_string.has("or_lesser")
			range_options.allow_greater = enum_string.has("or_greater")
		PROPERTY_HINT_ENUM:
			for value in enum_string:
				value = value.split(":")
				enum_values.set(value[0], int(value[1]))
	
	if hint_string.split(",").has("camera_targets") and get_tree().get_first_node_in_group("CameraTargets") != null:
		var i = 0
		for child in get_tree().get_first_node_in_group("CameraTargets").get_children():
			enum_values.set(child.name, i)
			i += 1
	
	return {"enum_values": enum_values, "range_options": range_options}

func get_property_boxes(type, enum_values, range_options):
	match type:
		TYPE_BOOL:
			var check_box = CheckBox.new()
			return [{"ref": check_box, "id": -1, "change": check_box.toggled, "value": "button_pressed"}]
		TYPE_INT, TYPE_FLOAT:
			if enum_values.keys().size() == 0:
				var spin_box = init_spin_slider(range_options, type == TYPE_INT)
				return [{"ref": spin_box, "id": -1, "change": spin_box.value_changed, "value": "value"}]
			else:
				var option_button = OptionButton.new()
				for key in enum_values.keys():
					option_button.add_item(key, enum_values[key])
				return [{"ref": option_button, "id": -1, "change": option_button.item_selected, "value": "selected"}]
		TYPE_STRING:
			var line_edit = LineEditNoFocus.new()
			return [{"ref": line_edit, "id": -1, "change": line_edit.text_changed, "value": "text"}]
		TYPE_COLOR:
			var color_picker = ColorPickerButton.new()
			return [{"ref": color_picker, "id": -1, "change": color_picker.color_changed, "value": "color"}]
		TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4, TYPE_VECTOR2I, TYPE_VECTOR3I, TYPE_VECTOR4I:
			var count = 2
			count += int(type == TYPE_VECTOR3 or type == TYPE_VECTOR3I)
			if type == TYPE_VECTOR4 or type == TYPE_VECTOR4I:
				count = 4
			
			var array = []
			for i in count:
				var spin_box = init_spin_slider()
				array.append({"ref": spin_box, "id": i, "change": spin_box.value_changed, "value": "value"})
			
			return array
		_:
			var warn_label = Label.new()
			warn_label.text = "UNSUPPORTED TYPE"
			warn_label.label_settings = error_label_settings
			add_child(warn_label)
			return []

func init_spin_slider(range_options: Dictionary = {}, force_int = false) -> SpinSlider:
	var spin_box = SpinSlider.new()
	spin_box.min_value = range_options.lower if range_options.has("lower") else 0.0
	spin_box.max_value = range_options.upper if range_options.has("upper") else 10.0
	spin_box.step = range_options.step if range_options.has("step") else 0.0
	spin_box.allow_lesser = range_options.allow_lesser if range_options.has("allow_lesser") else true
	spin_box.allow_greater = range_options.allow_greater if range_options.has("allow_greater") else true
	spin_box.show_range = range_options.keys().size() > 0
	if force_int:
		spin_box.step = 1.0
	return spin_box

func box_value_changed(new_value: Variant, source: Node):
	var event_params = event_param_info[source]
	value_changed.emit(event_params.name, event_params.member, new_value)
