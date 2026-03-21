extends Node
#Whether or not the timer is currently running
var player:CharacterBody2D
var paused:bool = false
var remaining_time:float = 617.0

@export var steal_sfx:AudioStream
@export var give_sfx:AudioStream
@export var main_menu_uid:String

@onready var _tree:SceneTree = get_tree()
@onready var _scene:Node = _tree.current_scene
@onready var _world:World2D = _scene.get_viewport().find_world_2d()
@onready var _space_state:PhysicsDirectSpaceState2D = _world.direct_space_state

var _current_target:Stealable
var _target_selected:bool = false

func _ready() -> void:
	_decide_process_mode()
	_tree.scene_changed.connect(_on_scene_change)
	SceneManager.transition_finished.connect(_decide_process_mode)

func _decide_process_mode() -> void:
	if ResourceUID.id_to_text(ResourceLoader.get_resource_uid(_scene.scene_file_path)) == main_menu_uid:
		set_process(false)
		print("not processing")
	else:
		set_process(true)
		print("processing")

func _on_scene_change() -> void:
	_tree = get_tree()
	_scene = _tree.current_scene
	_world = _scene.get_viewport().find_world_2d()
	_space_state = _world.direct_space_state

func _get_mouse_position() -> Vector2:
	
	if _scene:
		var viewport:Viewport = _scene.get_viewport()
		var screen_transform:Transform2D = viewport.get_screen_transform()
		var canvas_transform:Transform2D = viewport.canvas_transform
		var screenPos:Vector2 = viewport.get_mouse_position()
		#https://forum.godotengine.org/t/how-to-transform-screen-position-to-global-through-a-camera2d/38241/2
		return (screen_transform*canvas_transform).affine_inverse()*screenPos
	return Vector2.ZERO

func _get_object_at_mouse() -> Stealable:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = _get_mouse_position()
	query.collide_with_bodies = true
	query.collide_with_areas = false
	
	var result = _space_state.intersect_point(query, 1)
	if result.is_empty() or result[0].collider is not Stealable:
		return null
	return result[0].collider

signal timeout();
func add_time(seconds:float) -> void:
	remaining_time += seconds
func subtract_time(seconds:float) -> void:
	remaining_time -= seconds
func set_time(seconds:float) -> void:
	remaining_time = seconds
func set_player(new_player:CharacterBody2D) -> void:
	if player != new_player:
		#Make sure the old player object gets freed
		if player != null:
			player.queue_free()
		player = new_player


func _process(delta: float) -> void:
	if !_target_selected:
		var new_target:Stealable
		new_target = _get_object_at_mouse()
		if new_target != _current_target:
			if _current_target:
				_current_target.set_highlight(false)
			_current_target = new_target
	if _current_target:
		_current_target.set_highlight(true)
		_target_selected = true
		if Input.is_action_pressed("steal"):
			var time_stolen: float = _current_target.steal(delta)
			PlayerStats.add_time(time_stolen)
			if time_stolen > 0.0:
				ParticleManager.generate(_current_target.global_position, player, steal_sfx)
		elif Input.is_action_pressed("give"):
			var time_given: float = _current_target.give(delta)
			PlayerStats.subtract_time(time_given)
			if time_given > 0.0:
				ParticleManager.generate(player.global_position, _current_target, give_sfx)
		else:
			_target_selected = false

func _physics_process(delta: float) -> void:
	if !paused:
		if(remaining_time >= delta):
			remaining_time -= delta
		else:
			remaining_time = 0
		if(remaining_time <= 0):
			paused = true
			timeout.emit()
		
