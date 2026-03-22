class_name WinPopup
extends Control

@export var win_label:Label
@export var quote:Label
@export var main_menu_button:Button
@export var _main_menu_uid:StringName


func _ready() -> void:
	modulate.a = 0
	hide()
	main_menu_button.pressed.connect(_on_main_menu)

func open() -> void:
	get_tree().paused = true
	show()
	var tween:Tween = create_tween()
	tween.tween_property(self,"modulate",Color(modulate,1.),1)
	tween.tween_callback(main_menu_button.grab_focus)
	
func _on_main_menu() -> void:
	get_tree().paused = false
	SceneManager.change_scene(_main_menu_uid)
