extends Node

@export var play_button: Button
@export var level_menu: RightSideMenu

@export var options_button: Button
@export var options_menu: RightSideMenu


func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	
	play_button.grab_focus()


func toggle_level_menu() -> void:
	if level_menu.visible:
		level_menu.reset()
		return
	
	## Ensures the options menu is hidden before showing the level menu.
	if options_menu.visible:
		options_menu.reset()
	
	level_menu.display()


func toggle_options_menu() -> void:
	if options_menu.visible:
		options_menu.reset()
		return
	
	## Ensures the level menu is hidden before showing the options menu.
	if level_menu.visible:
		level_menu.reset()
	
	options_menu.display()


func _on_play_button_pressed() -> void:
	play_button.grab_focus()
	toggle_level_menu()


func _on_options_button_pressed() -> void:
	options_button.grab_focus()
	toggle_options_menu()
