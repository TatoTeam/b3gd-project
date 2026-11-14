extends OptionButton

@export var hidden_classes: PackedStringArray
@export var default_icon: Texture2D
@export var script_path: String
@export var selected_init: int = 0

var class_paths = []

func _ready() -> void:
	for global_class in ProjectSettings.get_global_class_list():
		if not ResourceLoader.exists(global_class.path):
			continue
		
		var loaded_class := load(global_class.path)
		if loaded_class != null && does_script_extend_class(loaded_class, script_path) && !loaded_class.is_abstract():
			if global_class.class in hidden_classes:
				continue
			
			var example = load(global_class.path).new()
			var class_icon = default_icon
			var path = example.get_script().resource_path
			var icon_path = path.substr(0, path.length() - 3) + ".png"
			if FileAccess.file_exists(icon_path):
				class_icon = load(icon_path)
			add_icon_item(class_icon, global_class.class)
			class_paths.append(global_class.path)
	
	selected = selected_init

func does_script_extend_class(base_script: Script, class_script_path: String) -> bool:
	var current: Script = base_script
	
	while current != null:
		if current.get_path() == class_script_path:
			return true
		current = current.get_base_script()
	
	return false
