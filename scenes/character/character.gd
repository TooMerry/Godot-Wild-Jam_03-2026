extends CharacterBody2D

@export var ground_speed:float = 300.0
@export var jump_height:float = 128
@export var air_speed = 200.0
@export var ground_friction = 0.6
@export var air_friction = 0.001
var jump_velocity:Vector2 = Vector2(0,-400)
var platform_velocity:Vector2
enum{GROUND,EDGE,JUMP,AIR}
var _state:int = GROUND
var speed:float
var can_move_horizontal:bool = true
var can_jump:bool = true
var falling:bool = false
var gravity:Vector2
var friction_coeff = ground_friction

var current_target: GrowObj = null

@onready var space_state = get_world_2d().direct_space_state


func _process(delta: float) -> void:
	current_target = _get_object_at_mouse()
	if current_target:
		if Input.is_action_pressed("steal"):
			var time_stolen: float = current_target.steal(delta)
			PlayerStats.add_time(time_stolen)
			if time_stolen > 0.0:
				ParticleManager.generate(current_target.global_position, self)
		elif Input.is_action_pressed("give"):
			var time_given: float = current_target.give(delta)
			PlayerStats.subtract_time(time_given)
			if time_given > 0.0:
				ParticleManager.generate(self.global_position, current_target)


func _get_object_at_mouse() -> Node2D:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	
	var result = space_state.intersect_point(query, 1)
	if result.is_empty() or result[0].collider is not GrowObj:
		return null
	
	return result[0].collider


func _physics_process(delta: float) -> void:
	gravity = get_gravity()
	var gravAngle = gravity.angle_to(Vector2.DOWN)
	#Set jump velocity so that the height is consistent an can be finely tuned. Since d = v^2/(2a), v = sqrt(2ad)
	jump_velocity = -gravity.normalized()*sqrt(2*gravity.length()*jump_height)
	_do_state()
	if falling:
		velocity += gravity * delta
	
	var direction := Input.get_axis("left", "right")
	var velProj:Vector2 = velocity.rotated(gravAngle)
	if direction && can_move_horizontal:
		velProj.x = direction*speed
		 #= direction * speed
	else:
		velProj.x = move_toward(velProj.x, 0, friction_coeff*gravity.length())
	velocity = velProj.rotated(-gravAngle)
		
	move_and_slide()

#States are mainly meant to enable animation differences
#in the future. There might be separate walk, jump, and
#fall animations later
func _do_state() -> void:
	match _state:
		GROUND:
			if Input.is_action_just_pressed("jump"):
				velocity += platform_velocity + jump_velocity
				_transition_state(JUMP)
				return
			if !is_on_floor():
				_transition_state(AIR)
				return
		EDGE:
			pass
		JUMP:
			if is_on_floor():
				_transition_state(GROUND)
				return
			#Checks whether gravity and velocity are pointing away from each other
			if gravity.dot(velocity) > 0:
				_transition_state(AIR)
				return
		AIR:
			if is_on_floor():
				_transition_state(GROUND)
				return
		_:
			pass

func _transition_state(to:int) -> void:
	_exit_state(_state)
	_enter_state(to)

func _enter_state(state:int) -> void:
	match state:
		GROUND:
			falling = false
			speed = ground_speed
			friction_coeff = ground_friction
			can_move_horizontal = true
		EDGE:
			pass
		JUMP:
			falling = true
			speed = air_speed
			friction_coeff = air_friction
			can_move_horizontal = true
		AIR:
			falling = true
			speed = air_speed
			friction_coeff = air_friction
			can_move_horizontal = true
		_:
			pass
	_state = state

func _exit_state(state:int) -> void:
	match state:
		GROUND:
			pass
		EDGE:
			pass
		JUMP:
			pass
		AIR:
			pass
		_:
			pass
