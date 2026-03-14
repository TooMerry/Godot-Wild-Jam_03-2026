class_name RightSideMenu
extends Control

const PROPERTY_POSITION_X: NodePath = ^"position:x"

@export var tween_duration: float = 0.2
@export var first_focus_target: Control

var _tween: Tween = null
var _displayed_position: float
var _hidden_position: float


func _ready() -> void:
	hide()
	var viewport_width: float = get_viewport_rect().size.x
	_displayed_position = viewport_width - size.x
	_hidden_position = viewport_width
	position.x = _hidden_position


func display() -> void:
	if visible:
		return
	
	if _tween != null and _tween.is_running():
		_tween.kill()
	
	show()
	_tween = create_tween()
	_tween.tween_property(self, PROPERTY_POSITION_X, _displayed_position, tween_duration)
	_tween.tween_callback(first_focus_target.grab_focus)


func reset() -> void:
	if not visible:
		return
	
	if _tween != null and _tween.is_running():
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, PROPERTY_POSITION_X, _hidden_position, tween_duration)
	_tween.tween_callback(hide)
