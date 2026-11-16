extends HBoxContainer

@export var editor_strumline: EditorStrumLine
@onready var receptor_count = $ReceptorCount

func _ready():
	receptor_count.text = str(editor_strumline.strumline.receptors.size())

func _on_add_receptor_pressed():
	editor_strumline.strumline.receptors.append(Receptor.new())
	receptor_count.text = str(editor_strumline.strumline.receptors.size())

func _on_remove_receptor_pressed():
	if editor_strumline.strumline.receptors.size() == 1: return
	editor_strumline.strumline.receptors.pop_back()
	receptor_count.text = str(editor_strumline.strumline.receptors.size())
