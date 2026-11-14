extends Node2D

@export var notes_texture: Texture2D
@onready var note_manager := get_tree().get_first_node_in_group("NoteManager")
@onready var strum_label: Control = get_parent().get_parent().get_node("%StrumLineLabel")
@onready var strum_line_root = get_parent().get_parent()

# I'm so sorry.
# "can you instead say uhm im uhm im the greatest uhm programmer ever" - mayo78
#                                            (who has not ever touched the engine codebase)
# "your actually bullying right now. what is wrong with you. STOP! What is this. what is wrong with you. What are you doing. Dude. No im not gonna say anything anymore. No you missed a few words actually. No go back, ok whatever. Add that. Whatever" - mayo78
const DEFINED_MULTIKEY_INDEXES:Dictionary = {
	1: [4],
	2: [5, 8],
	3: [0, 4, 3],
	4: [0, 1, 2, 3],
	5: [0, 1, 4, 2, 3],
	6: [0, 1, 3, 0, 2, 3],
	7: [0, 1, 3, 4, 0, 2, 3],
	8: [0, 1, 2, 3, 0, 1, 2, 3],
	9: [0, 1, 2, 3, 4, 0, 1, 2, 3],
	10: [0, 1, 2, 3, 5, 8, 0, 1, 2, 3],
	11: [0, 1, 2, 3, 5, 9, 8, 0, 1, 2, 3],
	12: [0, 1, 2, 3, 5, 6, 7, 8, 0, 1, 2, 3],
	13: [0, 1, 2, 3, 5, 6, 4, 7, 8, 0, 1, 2, 3],
	14: [0, 1, 2, 3, 5, 6, 8, 5, 7, 8, 0, 1, 2, 3],
	15: [0, 1, 2, 3, 5, 6, 8, 4, 5, 7, 8, 0, 1, 2, 3],
	16: [0, 1, 2, 3, 5, 6, 7, 8, 5, 6, 7, 8, 0, 1, 2, 3],
	17: [0, 1, 2, 3, 5, 6, 7, 8, 4, 5, 6, 7, 8, 0, 1, 2, 3],
	18: [0, 1, 2, 3, 5, 6, 7, 8, 0, 3, 5, 6, 7, 8, 0, 1, 2, 3],
	19: [0, 1, 2, 3, 5, 6, 7, 8, 0, 9, 3, 5, 6, 7, 8, 0, 1, 2, 3],
	20: [0, 1, 2, 3, 5, 6, 7, 8, 0, 1, 2, 3, 5, 6, 7, 8, 0, 1, 2, 3],
	21: [0, 1, 2, 3, 5, 6, 7, 8, 0, 1, 4, 2, 3, 5, 6, 7, 8, 0, 1, 2, 3],
}

var current_key_indexes: Array = [0, 1, 2, 3]

func update():
	if strum_line_root.strum_line.receptors.size() in DEFINED_MULTIKEY_INDEXES.keys():
		current_key_indexes = DEFINED_MULTIKEY_INDEXES[strum_line_root.strum_line.receptors.size()]
	else:
		current_key_indexes = []
		current_key_indexes.resize(strum_line_root.strum_line.receptors.size())
		current_key_indexes.fill(10)
	
	for receptor in get_children():
		remove_child(receptor)
		receptor.free()
	
	for receptor_id in range(strum_line_root.strum_line.receptors.size()):
		var texture_rect = TextureRect.new()
		texture_rect.texture = AtlasTexture.new()
		texture_rect.texture.atlas = notes_texture
		texture_rect.texture.region = Rect2(Vector2(current_key_indexes[receptor_id], 0) * 64, Vector2.ONE * 64)
		texture_rect.position = Vector2(receptor_id, -0.5) * 64
		texture_rect.size = Vector2.ONE * 64
		add_child(texture_rect)
