extends CharacterBody2D

@export var sprite:Sprite2D
@export var tree:AnimationTree

@export_category("Physics")
@export var ground_speed:float = 300.0
@export var jump_height:float = 128
@export var air_speed:float = 200.0
@export var ground_friction:float = 0.6
@export var air_friction:float = 0.001
#How much time the character can be in the air before state moves to air state
@export var air_time:float = 0.1
var _air_time_remaining = air_time

@export_category("Age Dependant")
#Time value after which character starts slowing
@export var slowing_threshold_time:float = 580
#Time at which speed is reduced to the minimum allowed
@export var max_slow_time:float = 617
@export_range(0,1,0.001) var min_speed_scale:float = 0.617
@export var shrinking_threshold_time = 200
@export_range(0,1,0.001) var min_scale_factor:float = 0.5

var _speed_scale:float = 1
var _scale_factor:float = 1


@onready var animation_state_machine:AnimationNodeStateMachinePlayback = tree["parameters/playback"]
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

func _ready() -> void:
	PlayerStats.set_player(self)


func _set_time_dependent_factors() -> void:
	var t:float = PlayerStats.remaining_time
	if t > shrinking_threshold_time:
		_scale_factor = 1.
	else:
		_scale_factor = lerpf(min_scale_factor,1,t/shrinking_threshold_time)
	
	if t < slowing_threshold_time:
			_speed_scale = 1.
	else:
		_speed_scale = lerpf(1,min_speed_scale,(t - slowing_threshold_time)/(max_slow_time - slowing_threshold_time))
	

func _physics_process(delta: float) -> void:
	_set_time_dependent_factors()
	
	scale = Vector2.ONE*_scale_factor
	if(get_gravity() != Vector2.ZERO):
		gravity = get_gravity()
		up_direction = -gravity.normalized()
	var gravAngle = gravity.angle_to(Vector2.DOWN)
	rotation = -gravAngle
	
	#Set jump velocity so that the height is consistent an can be finely tuned. Since d = v^2/(2a), v = sqrt(2ad)
	jump_velocity = -gravity.normalized()*sqrt(2*gravity.length()*jump_height)
	_do_state(delta)
	if !is_on_floor() || falling:
		velocity += gravity * delta
	
	var direction := Input.get_axis("left", "right")
	tree["parameters/ground/blend_position"] = direction
	var velProj:Vector2 = velocity.rotated(gravAngle)
	if direction && can_move_horizontal:
		sprite.flip_h = direction < 0
		velProj.x = direction*speed*_speed_scale
		 #= direction * speed
	else:
		velProj.x = move_toward(velProj.x, 0, friction_coeff*gravity.length())
	velocity = velProj.rotated(-gravAngle)
		
	move_and_slide()

#States are mainly meant to enable animation differences
#in the future. There might be separate walk, jump, and
#fall animations later
func _do_state(delta:float) -> void:
	match _state:
		GROUND:
			if Input.is_action_just_pressed("jump"):
				velocity += platform_velocity + jump_velocity
				_transition_state(JUMP)
				return
			if !is_on_floor():
				if(_air_time_remaining > 0):
					_air_time_remaining -= delta
				else:
					_transition_state(AIR)
					return
			else:
				_air_time_remaining = air_time
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
			animation_state_machine.travel("land")
			_air_time_remaining = air_time
		EDGE:
			pass
		JUMP:
			falling = true
			speed = air_speed
			friction_coeff = air_friction
			can_move_horizontal = true
			animation_state_machine.travel("jump")
		AIR:
			falling = true
			speed = air_speed
			friction_coeff = air_friction
			can_move_horizontal = true
			animation_state_machine.travel("air")
		_:
			pass
	_state = state

func _exit_state(state:int) -> void:
	match state:
		GROUND:
			_air_time_remaining = air_time
			pass
		EDGE:
			pass
		JUMP:
			pass
		AIR:
			pass
		_:
			pass
