class_name GrowObj extends AnimatableBody2D
@export var hitbox:CollisionPolygon2D
@export var sprite:Sprite2D
@export var animation_player:AnimationPlayer
@export var highlight_shader:ShaderMaterial
var grown:bool = false

var selected:bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)

func steal(seconds:float):
	grown = true
	animation_player.play("grow")
	PlayerStats.add_time(seconds)
	
func give(seconds:float):
	grown = false
	animation_player.play_backwards("grow")
	PlayerStats.add_time(-seconds)


func _input(event: InputEvent) -> void:
	if selected && event is InputEventMouseButton:
		if !grown && event.button_index == MOUSE_BUTTON_LEFT:
			steal(20)
		elif grown && event.button_index == MOUSE_BUTTON_RIGHT:
			give(20)
			
			
			

func _on_mouse_enter() -> void:
	selected = true
	sprite.material = highlight_shader;
	
func _on_mouse_exit() -> void:
	selected = false
	sprite.material = null
