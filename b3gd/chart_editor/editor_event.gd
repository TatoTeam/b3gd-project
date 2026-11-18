extends Control
class_name EditorEvent

const BUTTON_SIZE := Vector2(42.0, 36.0)
const LANE_WIDTH := 57.0

var event: Event

@onready var button: Button = $Button
@onready var arrow: NinePatchRect = $Arrow

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow.z_index = -1

func update_visuals(icon: Texture2D) -> void:
	if button.icon != icon:
		button.icon = icon

	arrow.offset_right = 39.0 + event.lane * LANE_WIDTH
