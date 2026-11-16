extends VBoxContainer
class_name EditorStrumLine

@onready var strum_line_drawer = $StrumLineDrawer

var strumline: StrumLine

func load_strumline(p_strumline: StrumLine):
	strumline = p_strumline
