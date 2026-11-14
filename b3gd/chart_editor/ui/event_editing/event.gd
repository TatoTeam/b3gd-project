extends Node2D

@onready var class_box = $Button

signal event_box_toggled(node: Node2D, event_id: int, toggled_on: bool)

var event_id = -1
var event_name = "":
	set(value):
		event_name = value
		class_box.text = value

var dragging = false

func _process(_delta: float) -> void:
	class_box.position.x = -class_box.size.x
	

func _on_button_toggled(toggled_on: bool) -> void:
	event_box_toggled.emit(self, event_id, toggled_on)

var event_held_down = false

func _on_button_button_down() -> void:
	event_held_down = true
	maybe_drag_event.call_deferred()
	await class_box.button_up
	event_held_down = false

func maybe_drag_event() -> void:
	var drag = false
	
	while event_held_down:
		if !class_box.get_rect().has_point(get_local_mouse_position()):
			drag = true
			break
		await get_tree().process_frame
	print(drag)
	
	if !drag:
		return
	# now we are really dragging
	
	dragging = true
