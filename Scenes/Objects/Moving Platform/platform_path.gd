class_name PlatformPath extends Path2D

var path_follow:PathFollow2D
@export var sprite:Sprite2D
@export var animatable_body:AnimatableBody2D
#Remote transform to set the position of the body
var remote:RemoteTransform2D

#Variables describing the movement of the platform
@export_category("Movement")
#Speed (in number of pixels per second) of the platform
@export var speed:float = 100;
@export var looping:bool = true:
	set(val):
		looping = val
		if !is_node_ready():
			return
		path_follow.loop = val
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
@export_range(0,360,0.1,"radians_as_degrees") var platform_rotation:float = 0.0:
	set(val):
		platform_rotation = val
		if !is_node_ready():
			return
		animatable_body.rotation = val
#Sets the scale of the platform
@export var platform_scale:Vector2 = Vector2.ZERO:
	set(val):
		platform_scale = val
		if !is_node_ready():
			return
		animatable_body.scale = val

@export_category("Sprite")
@export var texture:Texture2D:
	set(val):
		texture = val
		if !is_node_ready():
			return
		sprite.texture = texture
@export var hframes:int = 1:
	set(val):
		hframes = val
		if !is_node_ready():
			return
		sprite.hframes = val
@export var vframes:int = 1:
	set(val):
		vframes = val
		if !is_node_ready():
			return
		sprite.vframes = val	
@export var frame:int = 0:
	set(val):
		frame = val
		if !is_node_ready():
			return
		if hframes == 0 || vframes == 0:
			frame = -1;
			sprite.frame = -1;
			return
		var max_frame:int = hframes*vframes - 1
		if val < 0:
			val = 0
		if val > max_frame:
			val = max_frame
		
		sprite.frame = val
@export var highlight_shader:ShaderMaterial
		
@export_category("Collision")
@export var collision_shapes:Array[CollisionShape2D]
@export_flags_2d_physics var collision_layer:int = 1:
	set(val):
		collision_layer = val
		if !is_node_ready():
			return
		animatable_body.collision_layer = val
		
@export_flags_2d_physics var collision_mask:int = 1:
	set(val):
		collision_mask = val
		if !is_node_ready():
			return
		animatable_body.collision_mask = val
var selected:bool = false:
	set(val):
		selected = val
		if !is_node_ready():
			return
		if val:
			sprite.material = highlight_shader;
		else:
			sprite.material = null;

func _ready() -> void:
	if !animatable_body:
		animatable_body = StaticBody2D.new()
	animatable_body.mouse_entered.connect(_on_mouse_enter)
	animatable_body.mouse_exited.connect(_on_mouse_exit)
	
	if !sprite:
		sprite = Sprite2D.new()
		animatable_body.add_child(sprite)
	
	path_follow = PathFollow2D.new()
	
	path_follow.rotates = false
	path_follow.cubic_interp = false
	path_follow.loop = looping
	add_child(path_follow)
	path_follow.progress_ratio = 1
	max_progress = path_follow.progress * (2. if boomerang else 1.)
	path_follow.progress = get_real_progress(progress)
	remote = RemoteTransform2D.new()
	path_follow.add_child(remote)
	remote.remote_path = remote.get_path_to(animatable_body)
	
	sprite.global_position = animatable_body.global_position
	animatable_body.rotation = platform_rotation
	animatable_body.scale = platform_scale
	animatable_body.collision_layer = collision_layer
	animatable_body.collision_mask = collision_mask
	animatable_body.input_pickable = true
	if collision_shapes.is_empty():
		for child in animatable_body.get_children():
			if (child is CollisionShape2D) && (child.shape):
				collision_shapes.append(child)
	else:
		for shape in collision_shapes:
			animatable_body.add_child(shape)
	
	if !texture:
		texture = sprite.texture
	else:
		sprite.texture = texture
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.frame = frame

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
	
