class_name PauseMenu
extends Control

@export var left_menu:MarginContainer
@export var resume_button:Button
@export var main_menu_button:Button
@export var options_button:Button
@export var options_menu:OptionsMenu
@export var _main_menu_uid:StringName
@onready var _tree:SceneTree = get_tree()

func _ready() -> void:
	hide()
	resume_button.pressed.connect(close)
	main_menu_button.pressed.connect(_on_main_menu_press)
	options_button.pressed.connect(_on_options_button_pressed)

func _on_main_menu_press() -> void:
	_tree.paused = false
	SceneManager.change_scene(_main_menu_uid)

func _on_options_button_pressed() -> void:
	@warning_ignore("standalone_ternary")
	options_menu.reset() if options_menu.visible else options_menu.display()

var _tween:Tween

func open():
	if _tween && _tween.is_running():
		_tween.kill()
	_tree.paused = true
	show()
	_tween = create_tween()
	_tween.tween_property(left_menu,^"position:x",0.,0.2)
	_tween.tween_callback(resume_button.grab_focus)

signal game_unpaused
func close():
	if _tween && _tween.is_running():
		_tween.kill()
	options_menu.reset()
	_tween = create_tween()
	_tween.tween_property(left_menu,^"position:x",-left_menu.size.x,0.2)
	_tween.tween_callback(
		func():
			hide()
			_tree.paused = false
	)
	game_unpaused.emit()
