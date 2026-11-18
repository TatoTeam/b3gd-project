extends ItemList

@export var song_folder = "res://songs/"
@export var song_scene_name = "song.tscn"

func _ready() -> void:
	for song_dir in DirAccess.get_directories_at(song_folder):
		if DirAccess.get_files_at(song_folder + song_dir).has(song_scene_name):
			add_item(song_folder + song_dir)
		else:
			for song_subdir in DirAccess.get_directories_at(song_folder + song_dir):
				if DirAccess.get_files_at(song_folder + song_dir + "/" + song_subdir).has(song_scene_name):
					add_item(song_dir + "/" + song_subdir)

func option_pressed(index: int) -> void:
	get_tree().change_scene_to_file(get_item_text(index) + "/" + song_scene_name)
