extends Button

@export var scene_path: String


func _ready() -> void:
	pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	SceneManager.change_scene(scene_path)
