class_name PlatformPath extends Path2D

var path_follow:PathFollow2D
@export var _sprite:Sprite2D
@export var _animatable_body:AnimatableBody2D
#Remote transform to set the position of the body
var _remote:RemoteTransform2D

#Variables describing the movement of the platform
@export_category("Movement")
#Speed (in number of pixels per second) of the platform
@export var speed:float = 100;
@export var looping:bool = true
#If boomerang is true, the platform turns around when
#it reaches the end of its path. Otherwise, it
#teleports back to the start of its path
@export var boomerang:bool = false
#Progress (in number of pixels travelled along the curve)
@export var progress:float = 0:
	set(val):
		if is_equal_approx(val,progress):
			return
		progress = float_mod(val,max_progress)
		progress_ratio = progress/max_progress
		if !is_node_ready():
			return
		path_follow.progress = get_real_progress(progress)
#Maximum possible progress (arc length of the curve).
#This gets multiplied by two if boomerang is true, so
#that the "true path" is a full cycle of the boomerang
#movement
var max_progress:float = curve.get_baked_length() * (2. if boomerang else 1.)
@export_range(0,1,0.01) var progress_ratio:float = 0:
	set(val):
		if is_equal_approx(val,progress_ratio):
			return
		progress_ratio = val
		progress = max_progress*progress_ratio
		

@export_category("Platform Transform")
#Sets the rotation of the platform
@export_range(0,360,0.1,"radians_as_degrees") var _platform_rotation:float = 0.0
#Sets the scale of the platform
@export var _platform_scale:Vector2 = Vector2.ZERO

@export_category("Sprite")
@export var _texture:Texture2D
@export var _hframes:int = 1
@export var _vframes:int = 1
@export var _frame:int = 0
@export var _highlight_shader:ShaderMaterial
		
@export_category("Collision")
@export var _collision_shapes:Array[CollisionShape2D]
@export_flags_2d_physics var _collision_layer:int = 1
@export_flags_2d_physics var _collision_mask:int = 1
var selected:bool = false

func _ready() -> void:
	if !_animatable_body:
		_animatable_body = StaticBody2D.new()
	_animatable_body.mouse_entered.connect(_on_mouse_enter)
	_animatable_body.mouse_exited.connect(_on_mouse_exit)
	
	if !_sprite:
		_sprite = Sprite2D.new()
		_animatable_body.add_child(_sprite)
	
	path_follow = PathFollow2D.new()
	
	path_follow.rotates = false
	path_follow.cubic_interp = false
	path_follow.loop = looping
	add_child(path_follow)
	path_follow.progress_ratio = 1
	max_progress = path_follow.progress * (2. if boomerang else 1.)
	path_follow.progress = get_real_progress(progress)
	_remote = RemoteTransform2D.new()
	path_follow.add_child(_remote)
	_remote.remote_path = _remote.get_path_to(_animatable_body)
	
	_sprite.global_position = _animatable_body.global_position
	_animatable_body.rotation = _platform_rotation
	_animatable_body.scale = _platform_scale
	_animatable_body.collision_layer = _collision_layer
	_animatable_body.collision_mask = _collision_mask
	_animatable_body.input_pickable = true
	set_collision_shapes(_collision_shapes)
	
	set_platform_texture(_texture)
	_sprite.hframes = _hframes
	_sprite.vframes = _vframes
	_sprite.frame = _frame

#Function for finding numbers "mod" floats
func float_mod(val:float,mod_val:float)->float:
	if val < mod_val && val > 0:
		return val
	var div:float = val/mod_val
	return val - mod_val*floorf(div)

#Get the actual number for the path_follow's progress
func get_real_progress(prog:float)->float:
	if !boomerang:
		return float_mod(prog,max_progress)
	#Gives the boomerang effect. moves forward
	#until we get to max_progress/2, then moves backwards
	return max_progress/2 - abs(float_mod(prog,max_progress) - max_progress/2)

func steal(seconds:float) -> void:
	PlayerStats.add_time(seconds)
	progress += speed*seconds

func give(seconds:float) -> void:
	PlayerStats.add_time(-seconds)
	progress -= speed*seconds

func _input(event: InputEvent) -> void:
	if selected && event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			steal(5)
			selected = false
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			give(5)
			selected = false

func _on_mouse_enter() -> void:
	selected = true;

func _on_mouse_exit() -> void:
	selected = false;

func _physics_process(delta: float) -> void:
	progress+=speed*delta

func toggle_looping() -> void:
	looping = !looping
	path_follow.loop = looping

func toggle_boomerang() -> void:
	max_progress *= 0.5 if boomerang else 2.
	boomerang = !boomerang

func set_platform_rotation(rads:float) -> void:
	_animatable_body.rotation = rads
	_platform_rotation = rads

func set_platform_scale(scale_vec:Vector2) -> void:
	_animatable_body.scale = scale_vec
	_platform_scale = scale_vec

func set_platform_texture(tex:Texture2D) -> void:
	_texture = tex
	if !_texture:
		_texture = _sprite.texture
	else:
		_sprite.texture = _texture

func set_platform_hframes(frames:int) -> void:
	_sprite.hframes = frames
	_hframes = frames

func set_platform_vframes(frames:int) -> void:
	_sprite.vframes = frames
	_vframes = frames

func set_platform_frame(val:int) -> void:
	_frame = val
	if _hframes == 0 || _vframes == 0:
		_frame = -1;
		_sprite.frame = -1;
		return
	var max_frame:int = _hframes*_vframes - 1
	if val < 0:
		val = 0
	if val > max_frame:
		val = max_frame
	_sprite.frame = val

func set_collision_layer(layer:int) -> void:
	_animatable_body.collision_layer = layer
	_collision_layer = layer

func set_collision_mask(mask:int) -> void:
	_animatable_body.collision_mask = mask
	_collision_mask = mask

func set_collision_shapes(shapes:Array[CollisionShape2D]) -> void:
	_collision_shapes = shapes
	if _collision_shapes.is_empty():
		for child in _animatable_body.get_children():
			if (child is CollisionShape2D) && (child.shape):
				_collision_shapes.append(child)
	else:
		for shape in _collision_shapes:
			_animatable_body.add_child(shape)

func set_selected(val:bool) -> void:
	_sprite.material = _highlight_shader if val else null
	selected = val
