extends Control
class_name EditorEventDrawer

const EVENT_THEME: Theme = preload("uid://djr1hg1crhdfd")
const EVENT_ICON: Texture2D = preload("uid://bt0p345u448ww")
const EVENT_LINE: Texture2D = preload("uid://cka5y22a126yx")
const BUTTON_SIZE := Vector2(42.0, 36.0)

@onready var main_container = $"../../.."


var line_style: StyleBoxTexture
var _class_icon_paths: Dictionary = {}
var _script_icons: Dictionary = {}
var _icons_initialized := false

var receptor_y_pos: float:
	get():
		return main_container.size.y * ChartEditor.instance.settings.receptor_offset

var pixels_per_second: float:
	get():
		return ChartEditor.instance.settings.NOTE_SIZE * ChartEditor.instance.settings.editor_zoom

func _ready() -> void:
	line_style = StyleBoxTexture.new()
	line_style.texture = EVENT_LINE
	line_style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	line_style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE

func _process(_delta: float) -> void:
	queue_redraw()

func time_to_y(time: float) -> float:
	return receptor_y_pos + (time - ChartEditor.song_audio_player.song_position_seconds) * pixels_per_second

func y_to_time(y: float) -> float:
	return ChartEditor.song_audio_player.song_position_seconds + (y - receptor_y_pos) / pixels_per_second

func y_to_snapped_time(y: float) -> float:
	return ChartEditor.instance.settings.snap_time(y_to_time(y))

func get_event_position(lane: int, time: float) -> Vector2:
	return Vector2(-lane * (BUTTON_SIZE.x + 15), time_to_y(time))

func get_script_icon(script: Script) -> Texture2D:
	if script == null:
		return EVENT_ICON
	if _script_icons.has(script):
		return _script_icons[script]
	
	if not _icons_initialized:
		for entry in ProjectSettings.get_global_class_list():
			_class_icon_paths[entry["path"]] = entry["icon"]
		_icons_initialized = true
	
	var path: String = _class_icon_paths.get(script.resource_path, "")
	var icon: Texture2D = EVENT_ICON
	if not path.is_empty():
		icon = load(path) as Texture2D
		if icon == null:
			icon = EVENT_ICON
	
	_script_icons[script] = icon
	return icon

func draw_event(target: CanvasItem, lane: int, time: float, script: Script = null) -> void:
	var event_position := get_event_position(lane, time)
	var button_rect := Rect2(event_position - Vector2(BUTTON_SIZE.x, BUTTON_SIZE.y / 2.0), BUTTON_SIZE)
	var button_style := EVENT_THEME.get_stylebox("normal", "Button")
	
	target.draw_style_box(button_style, button_rect)
	
	var icon := get_script_icon(script)
	var icon_position := button_rect.position + (button_rect.size - icon.get_size()) / 2.0
	target.draw_texture(icon, icon_position)
	
func draw_event_line(target: CanvasItem, lane: int, time: float) -> void:
	var event_position := get_event_position(lane, time)
	var line_rect := Rect2(event_position + Vector2(-1.0, -3.0), Vector2(40.0 + lane * BUTTON_SIZE.x, 6.0))
	target.draw_style_box(line_style, line_rect)

func _draw() -> void:
	if ChartEditor.instance == null or ChartEditor.instance.chart == null:
		return
	
	for event in ChartEditor.instance.chart.events:
		if event != null:
			draw_event_line(self, event.lane, event.time)
	
	for event in ChartEditor.instance.chart.events:
		if event != null:
			draw_event(self, event.lane, event.time, event.get_script())
