class_name RightSideMenu
extends Control

const PROPERTY_POSITION_X: NodePath = ^"position:x"

@export var tween_duration: float = 0.2
@export var first_focus_target: Control

var tween: Tween = null
var displayed_position: float
var hidden_position: float


func _ready() -> void:
	hide()
	var viewport_width: float = get_viewport_rect().size.x
	displayed_position = viewport_width - size.x
	hidden_position = viewport_width
	position.x = hidden_position


func display() -> void:
	if visible:
		return
	
	if tween != null and tween.is_running():
		tween.kill()
	
	show()
	tween = create_tween()
	tween.tween_property(self, PROPERTY_POSITION_X, displayed_position, tween_duration)
	tween.tween_callback(first_focus_target.grab_focus)


func reset() -> void:
	if not visible:
		return
	
	if tween != null and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, PROPERTY_POSITION_X, hidden_position, tween_duration)
	tween.tween_callback(hide)
