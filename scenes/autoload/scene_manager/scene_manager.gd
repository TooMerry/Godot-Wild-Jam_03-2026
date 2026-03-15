extends Node
## Global scene transition manager.
##
## This class handles scene loading, unloading, and visual transitions
## between scenes.[br]
## It should be registered as an Autoload so it can be accessed globally.[br]
## Transitions are defined in [member transition_map] and rendered using
## [member transition_rect].[br]
## [br]
## Usage example:
## [codeblock]
## # Change to level 2 scene using the default transition
## SceneManager.change_scene("res://levels/level_2.tscn")
##
## # Change scene using a custom transition named "fade"
## SceneManager.change_scene("res://levels/level_3.tscn", "fade")
## [/codeblock]

## Resource type hint used when loading scenes.
const TYPE_HINT_PACKED_SCENE: String = "PackedScene"

## Mapping between transition names and the shader materials used
## to render them on [member transition_rect].
@export var transition_map: Dictionary[StringName, ShaderMaterial] = {}

## Duration of the transition animation in seconds.
@export var transition_time: float = 0.4

## Fullscreen [ColorRect] used to render the transition shader.
@export var transition_rect: ColorRect

## Indicates whether a scene change is currently in progress.
var is_changing: bool = false

## Reference to the SceneTree.
@onready var _tree: SceneTree = get_tree()

## Reference to the root window (top-level node) of the scene tree.
@onready var _tree_root: Window = _tree.root

## Currently active scene node.
@onready var _current_scene: Node = _tree.current_scene


## Requests a scene change to the one at the given [param path].[br]
## [br]
## If a transition is already in progress or the path is invalid,
## the request is ignored.[br]
## [br]
## [param transition_name] specifies the transition shader to use.
## It must exist in [member transition_map].
func change_scene(path: String, transition_name: StringName = &"circular_sweep") -> void:
	if is_changing or path.is_empty():
		return
	
	if not ResourceLoader.exists(path, TYPE_HINT_PACKED_SCENE):
		return
	
	_change_scene_internal.call_deferred(path, transition_name)


## Internal implementation of [method change_scene].[br]
## [br]
## This method performs the full scene replacement workflow:[br]
## 1. Plays the transition-out animation.[br]
## 2. Unloads the current scene.[br]
## 3. Loads and instantiates the new scene.[br]
## 4. Adds it to the scene tree and sets it as the current scene.[br]
## 5. Plays the transition-in animation.[br]
## [br]
## This method should not be called directly. It is invoked through
## [method change_scene] using [method Object.call_deferred].
func _change_scene_internal(path: String, transition_name: StringName) -> void:
	if is_changing or path.is_empty():
		return
	
	is_changing = true
	transition_rect.set_material(transition_map[transition_name])
	await _transition_out()
	
	var next_scene: PackedScene = ResourceLoader.load(
			path,
			TYPE_HINT_PACKED_SCENE,
			ResourceLoader.CACHE_MODE_IGNORE)
	if next_scene != null:
		_unload_scene()
		_current_scene = next_scene.instantiate()
		_current_scene.set_scene_file_path(path)
		
		await _tree.create_timer(0.0).timeout
		
		_tree_root.add_child(_current_scene)
		_tree.set_current_scene(_current_scene)
	
	await _transition_in()
	is_changing = false


## Frees the currently active scene if one exists.[br]
## [br]
## The scene is queued for deletion using [method Node.queue_free],
## and the internal reference is cleared.
func _unload_scene() -> void:
	if _current_scene:
		_current_scene.queue_free()
		_current_scene = null


## Plays the transition [b]closing[/b] animation.[br]
## [br]
## The transition rectangle is temporarily reparented to the scene tree
## root so it renders above all other nodes. The shader parameter
## [code]progress[/code] is animated from [code]0.0[/code] to
## [code]1.0[/code].[br]
## [br]
## Returns the [Signal] emitted when the tween finishes so callers can
## [code]await[/code] the end of the transition.
func _transition_out() -> Signal:
	transition_rect.reparent(_tree_root)
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


## Plays the transition [b]opening[/b] animation.[br]
## [br]
## The transition rectangle is temporarily reparented to the scene tree
## root so it renders above all other nodes. The shader parameter
## [code]progress[/code] is animated from [code]1.0[/code] to
## [code]0.0[/code], revealing the new scene.[br]
## [br]
## Once the animation finishes, the transition rectangle is hidden and
## returned to its original parent.[br]
## [br]
## Returns the [Signal] emitted when the tween finishes so callers can
## [code]await[/code] the end of the transition.
func _transition_in() -> Signal:
	transition_rect.reparent(_tree_root)
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
