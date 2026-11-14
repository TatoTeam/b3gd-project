extends PanelContainer

@onready var strum_line_label = %StrumLineLabel
@onready var receptor_count = %ReceptorCount
@onready var mute_check_box = %MuteCheckBox
@onready var cpu_check_box = %CPUCheckBox
@onready var strum_line_root = get_parent()

func update():
	strum_line_label.text = str(strum_line_root.strum_line_idx)
	receptor_count.text = str(strum_line_root.strum_line.receptors.size())
	cpu_check_box.button_pressed = strum_line_root.strum_line.cpu
