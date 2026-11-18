@icon("uid://u533g6m2i1ea")
class_name EventTweenCustom extends EventTween

@export var tween_tracker_path: String
@export var tween_tracker_property: String
@export var tween_node_path: String
@export var tween_property: String
@export var tween_value: Variant
@export var tween_multiply: bool:
	set(value):
		tween_multiply = value
		multiply = tween_multiply

func init():
	var tween_node = parent.get_tree().current_scene.get_node(tween_node_path)
	var tween_tracker_node = parent.get_tree().current_scene.get_node_or_null(tween_tracker_path)
	
	tween_tracker.node = tween_tracker_node
	tween_tracker.property = tween_tracker_property
	
	to_tween.node = tween_node
	to_tween.property = tween_property
	to_tween.value_node = self
	to_tween.value_property = "tween_value"
	multiply = tween_multiply
