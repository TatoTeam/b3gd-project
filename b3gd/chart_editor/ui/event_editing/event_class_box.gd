extends OptionButton

@export var hidden_classes: PackedStringArray
@export var default_icon: Texture2D

var class_paths = []

func _ready() -> void:
	for global_class in ProjectSettings.get_global_class_list():
		var example = load(global_class.path).new()
		if example is Event:
			if global_class.class in hidden_classes:
				continue
			
			var class_icon = default_icon
			var path = example.get_script().resource_path
			var icon_path = path.substr(0, path.length() - 3) + ".png"
			if FileAccess.file_exists(icon_path):
				class_icon = load(icon_path)
			add_icon_item(class_icon, global_class.class)
			class_paths.append(global_class.path)
	selected = -1
