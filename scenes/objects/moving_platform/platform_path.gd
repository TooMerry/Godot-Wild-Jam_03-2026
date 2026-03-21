class_name PlatformPath extends Stealable

var path_follow:PathFollow2D
@export var _sprite:Sprite2D
@export var _path:Path2D

#Remote transform to set the position of the body
var _remote:RemoteTransform2D

#Variables describing the movement of the platform
@export_category("Movement")
@export var time_before_movement_start:float = 0.
#Speed (in number of pixels per second) of the platform
@export var speed:float = 100;
@export var looping:bool = true
#If boomerang is true, the platform turns around when
#it reaches the end of its path. Otherwise, it
#teleports back to the start of its path
@export var boomerang:bool = false
#Progress (in number of pixels travelled along the curve)
var progress:float = 0:
	set(val):
		if is_equal_approx(val,progress):
			return
		progress = float_mod(val,max_progress) if looping else clampf(val,0,max_progress*0.9999)
		if !is_node_ready():
			return
		path_follow.progress = get_real_progress(progress)
#Maximum possible progress (arc length of the curve).
#This gets multiplied by two if boomerang is true, so
#that the "true path" is a full cycle of the boomerang
#movement
@onready var max_progress:float = _path.curve.get_baked_length() * (2. if boomerang else 1.)
@export_range(0,1,0.01) var progress_ratio:float = 0:
	set(val):
		if is_equal_approx(val,progress_ratio):
			return
		progress_ratio = val
		progress = max_progress*progress_ratio
		

@export_category("Sprite")
@export var _texture:Texture2D
@export var _hframes:int = 1
@export var _vframes:int = 1
@export var _frame:int = 0
		
@export_category("Time")
@export var _time_transfer_multiplier:float = 2.:
	set(value):
		time_transfer_multiplier = value
		_time_transfer_multiplier = value
#Maximum number of seconds back the platform can be from the current moment.
@export var max_temporal_offset:float = 4.
@export var min_temporal_offset:float = -4.
var temporal_offset:float = 0


func _ready() -> void:
	time_transfer_multiplier = _time_transfer_multiplier
	if !_sprite:
		_sprite = Sprite2D.new()
		add_child(_sprite)
	
	path_follow = PathFollow2D.new()
	
	path_follow.rotates = false
	path_follow.cubic_interp = false
	path_follow.loop = looping
	setup.call_deferred()
	input_pickable = true

func setup() -> void:
	_path.add_child(path_follow)
	path_follow.progress_ratio = 1
	max_progress = path_follow.progress * (2. if boomerang else 1.)
	path_follow.progress = get_real_progress(progress)
	print(path_follow.progress,progress)
	_remote = RemoteTransform2D.new()
	path_follow.add_child(_remote)
	_remote.remote_path = _remote.get_path_to(self)

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

func steal(seconds:float) -> float:
	if _internal_time <= seconds || temporal_offset <= min_temporal_offset:
		return 0.
	temporal_offset -= min(seconds,temporal_offset - min_temporal_offset)
	#_internal_time -= seconds
	var offset_time:float = _internal_time + temporal_offset
	if offset_time < time_before_movement_start:
		return seconds
	var internal_time_adj = offset_time - time_before_movement_start
	if looping || (internal_time_adj*speed < max_progress && internal_time_adj >= 0):
		progress -= speed*seconds
	return seconds

func give(seconds:float) -> float:
	if temporal_offset >= max_temporal_offset:
		return 0.
	temporal_offset += min(seconds,max_temporal_offset - temporal_offset)
	var offset_time:float = _internal_time + temporal_offset
	if offset_time < time_before_movement_start:
		return seconds
	var internal_time_adj = offset_time - time_before_movement_start
	if looping || (internal_time_adj*speed < max_progress && internal_time_adj >= 0):
		progress += speed*seconds
	return seconds

var _internal_time:float = 0.

func _do_time_step(delta:float) -> void:
	_internal_time += delta
	if(_internal_time + temporal_offset > time_before_movement_start):
		var next_prog:float = progress + speed * delta
		if looping || (next_prog < max_progress && next_prog >= 0):
			progress = next_prog

func _physics_process(delta: float) -> void:
	_do_time_step(delta)

func toggle_looping() -> void:
	looping = !looping
	path_follow.loop = looping

func toggle_boomerang() -> void:
	max_progress *= 0.5 if boomerang else 2.
	boomerang = !boomerang

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

var transferring:bool = false
func set_highlight(enabled:bool) -> void:
	_sprite.set_instance_shader_parameter("is_enabled",enabled)
