extends Node2D

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")

@export var note_scene: PackedScene
@export var notes_texture: Texture2D
@export var notes_color_mask: Texture2D
@export var quant_colors: PackedColorArray

@onready var note_manager := get_tree().get_first_node_in_group("NoteManager")
@onready var strum_label: Control = get_parent().get_parent().get_node("%StrumLineLabel")
@onready var strum_line_root = get_parent().get_parent().get_parent()
@onready var receptors = %Receptors

var loaded_icons = {}

func update():
	var region_textures_top = []
	var region_textures_mask = []
	
	for x in range(11):
		var note_vs_hold_top = []
		var note_vs_hold_mask = []
		for y in range(2):
			var atlas = AtlasTexture.new()
			atlas.atlas = notes_texture
			atlas.region.size = Vector2.ONE * 64
			atlas.region.position = Vector2(x, y + 1) * 64
			note_vs_hold_top.append(atlas)
			
			var atlas2 = AtlasTexture.new()
			atlas2.atlas = notes_color_mask
			atlas2.region.size = Vector2.ONE * 64
			atlas2.region.position = Vector2(x, y + 1) * 64
			note_vs_hold_mask.append(atlas2)
			
		region_textures_top.append(note_vs_hold_top)
		region_textures_mask.append(note_vs_hold_mask)
	
	var child_id = 0
	for receptor_id in range(strum_line_root.strum_line.receptors.size()):
		for note in strum_line_root.strum_line.receptors[receptor_id].notes:
			var note_y = note.time
			var note_length = note.length
			var note_instance = null
			
			if child_id < get_children().size():
				note_instance = get_children()[child_id]
			else:
				note_instance = note_scene.instantiate()
				add_child(note_instance)
			
			note_instance.position.y = note_y * 64
			note_instance.position.x = receptor_id * 64
			var quant_color = quant_colors[get_quant_id(note.time)]
			note_instance.get_node("ScaleOrigin/Note/Color").modulate = quant_color
			note_instance.get_node("Hold/Color").modulate = quant_color
			
			var note_image_id = receptors.current_key_indexes[receptor_id]
			
			note_instance.get_node("ScaleOrigin/Note").texture = region_textures_top[note_image_id][0]
			note_instance.get_node("ScaleOrigin/Note/Color").texture = region_textures_mask[note_image_id][0] 
			
			var note_path = note.get_script().resource_path
			var note_icon_path = note_path.substr(0, note_path.length() - 3) + ".png"
			if loaded_icons.has(note_icon_path):
				note_instance.get_node("ScaleOrigin/TypeTexture").texture = loaded_icons[note_icon_path]
			elif FileAccess.file_exists(note_icon_path):
				loaded_icons[note_icon_path] = load(note_icon_path)
				note_instance.get_node("ScaleOrigin/TypeTexture").texture = loaded_icons[note_icon_path]
			
			note_instance.get_node("ScaleOrigin/TypeTexture").show()
			
			child_id += 1
			
			if is_zero_approx(note_length):
				note_instance.get_node("Hold").hide()
			else:
				note_instance.get_node("Hold").show()
				note_instance.get_node("Hold").texture = region_textures_top[note_image_id][1]
				note_instance.get_node("Hold").scale.y = note_length
	
	for child in get_children().slice(child_id):
		child.queue_free()

const QUANT_LIST = [4,8,12,16,24,32,48,64]

func get_quant_id(note_time):
	var note_beat = song_audio_player.get_beat_from_seconds(note_time)
	var note_beat_sm: int = round(note_beat * 48.0)
	for i in QUANT_LIST.size():
		if note_beat_sm % (192 / QUANT_LIST[i]) == 0:
			return i
	return 8
