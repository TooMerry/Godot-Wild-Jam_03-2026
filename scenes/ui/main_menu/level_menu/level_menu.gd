class_name LevelMenu
extends RightSideMenu

@export var level_buttons: Array[Button] = []


func _ready() -> void:
	super._ready()
	
	for i: int in SaveManager.unlocked_levels:
		var level_button: Button = level_buttons.get(i)
		if level_button:
			level_button.set_disabled(false)
