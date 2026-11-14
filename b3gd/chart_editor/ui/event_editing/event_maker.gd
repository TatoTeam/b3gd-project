extends Node2D

@onready var event_container = get_parent().get_parent()
@onready var song_scrubber = get_tree().get_first_node_in_group("ChartEditor").get_node("%SongScrubber")
@onready var class_box = $ClassBox

@warning_ignore("unused_signal")
signal create_event(time, type)

var mouse_time = 0

var is_mouse_over = false

func _ready() -> void:
	queue_free()

func _process(_delta: float) -> void:
	var mouse_rect_position = event_container.get_local_mouse_position()
	
	is_mouse_over = mouse_rect_position.x < 0
	if is_mouse_over:
		var scroll_area = get_node("%WorkAreaScroll")
		var scroll_local_mouse_pos = scroll_area.get_local_mouse_position()
		is_mouse_over = Rect2(Vector2.ZERO, scroll_area.size).has_point(scroll_local_mouse_pos)
	
	visible = is_mouse_over
	var local_mouse_position = get_parent().get_local_mouse_position()
	
	class_box.position.x = -class_box.size.x
	
	mouse_time = local_mouse_position.y / 64.0
	mouse_time = song_scrubber.get_snapped_seconds(mouse_time)
	if !class_box.button_pressed:
		position.y = mouse_time * 64.0

func _on_class_box_item_selected(_index: int) -> void:
	if class_box.selected == -1:
		return
	class_box.selected = -1
