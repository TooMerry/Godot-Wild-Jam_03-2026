class_name GameOverMenu
extends Control

@export var game_over_label:Label
@export var epitaph_label:Label
@export var retry_button:Button
@export var main_menu_button:Button
@export var _main_menu_uid:StringName
@export var epitaphs:Array[String]


func _ready() -> void:
	modulate.a = 0
	hide()
	retry_button.pressed.connect(_on_retry)
	main_menu_button.pressed.connect(_on_main_menu)
	if epitaphs && !epitaphs.is_empty():
		epitaph_label.text = epitaphs[randi_range(0,epitaphs.size() - 1)]

func open() -> void:
	get_tree().paused = true
	show()
	var tween:Tween = create_tween()
	tween.tween_property(self,"modulate",Color(modulate,1.),1)
	tween.tween_callback(retry_button.grab_focus)

func close() -> void:
	pass

func _on_retry() -> void:
	#Change scene back to the current scene, thus resetting it
	get_tree().paused = false
	SceneManager.change_scene(get_tree().current_scene.scene_file_path)
	

func _on_main_menu() -> void:
	get_tree().paused = false
	SceneManager.change_scene(_main_menu_uid)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
