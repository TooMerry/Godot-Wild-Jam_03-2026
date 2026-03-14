extends Node

const TYPE_HINT_PACKED_SCENE: String = "PackedScene"

@export var transition_map: Dictionary[StringName, ShaderMaterial] = {}
@export var transition_time: float = 0.4
@export var transition_rect: ColorRect

var is_changing: bool = false

@onready var tree: SceneTree = get_tree()
@onready var tree_root: Window = tree.root
@onready var current_scene: Node = tree.current_scene


func change_scene(path: String, transition_name: StringName = &"circular_sweep") -> void:
	if is_changing or path.is_empty():
		return
	
	if not ResourceLoader.exists(path, TYPE_HINT_PACKED_SCENE):
		return
	
	replace_scene.call_deferred(path, transition_name)


func replace_scene(path: String, transition_name: StringName) -> void:
	if is_changing or path.is_empty():
		return
	
	is_changing = true
	transition_rect.set_material(transition_map[transition_name])
	await transition_out()
	
	var next_scene: PackedScene = ResourceLoader.load(
			path,
			TYPE_HINT_PACKED_SCENE,
			ResourceLoader.CACHE_MODE_IGNORE)
	if next_scene != null:
		unload_scene()
		current_scene = next_scene.instantiate()
		current_scene.set_scene_file_path(path)
		
		await tree.create_timer(0.0).timeout
		
		tree_root.add_child(current_scene)
		tree.set_current_scene(current_scene)
	
	await transition_in()
	is_changing = false


func unload_scene() -> void:
	if current_scene:
		current_scene.queue_free()


func transition_out() -> Signal:
	transition_rect.reparent(tree_root)
	transition_rect.set_instance_shader_parameter("inverted", false)
	transition_rect.show()
	
	var tween: Tween = transition_rect.create_tween()
	tween.tween_property(
			transition_rect,
			"material:shader_parameter/progress",
			1.0,
			transition_time)\
			.set_trans(Tween.TRANS_LINEAR)\
			.set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(transition_rect.reparent.bind(self))
	return tween.finished


func transition_in() -> Signal:
	transition_rect.reparent(tree_root)
	transition_rect.set_instance_shader_parameter("inverted", true)
	transition_rect.show()
	
	var tween: Tween = transition_rect.create_tween()
	tween.tween_property(
			transition_rect,
			"material:shader_parameter/progress",
			0.0,
			transition_time)\
			.set_trans(Tween.TRANS_LINEAR)\
			.set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(transition_rect.hide)
	tween.tween_callback(transition_rect.reparent.bind(self))
	return tween.finished
