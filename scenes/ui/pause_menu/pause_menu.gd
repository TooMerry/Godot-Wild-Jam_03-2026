extends Control

@export var left_menu:MarginContainer
@export var resume_button:Button
@export var main_menu_button:Button
@export var options_button:Button
@export var options_menu:OptionsMenu
@onready var _tree:SceneTree = get_tree()

func _ready() -> void:
	resume_button.pressed.connect(close)
	main_menu_button.pressed.connect(
		func():
			_tree.paused = false
			SceneManager.change_scene(&"res://scenes/ui/main_menu/main_menu.tscn")
	)
	options_button.pressed.connect(func(): options_menu.reset() if options_menu.visible else options_menu.display())
	open()
	
var _tween:Tween

func open():
	print("test")
	if _tween && _tween.is_running():
		_tween.kill()
	_tree.paused = true
	show()
	_tween = create_tween()
	_tween.tween_property(left_menu,^"position:x",0.,1.)
	_tween.tween_callback(resume_button.grab_focus)

func close():
	if _tween && _tween.is_running():
		_tween.kill()
	options_menu.reset()
	_tween = create_tween()
	_tween.tween_property(left_menu,^"position:x",-left_menu.size.x,1.)
	_tween.tween_callback(
		func():
			hide()
			_tree.paused = false
	)
