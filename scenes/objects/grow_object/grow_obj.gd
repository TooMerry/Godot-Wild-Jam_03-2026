@tool
class_name GrowObj
extends AnimatableBody2D

@export_range(0.0, 1.0, 0.01) var initial_progress: float = 0.0:
	set(value):
		initial_progress = value
		if not is_inside_tree():
			return
		
		var delta: float = (value - animation_player.current_animation_position)
		animation_player.advance(delta)

@export var sprite: Sprite2D
@export var animation_player: AnimationPlayer

var is_hovered: bool = false


func _ready() -> void:
	animation_player.play(&"grow")
	animation_player.pause()
	animation_player.advance(initial_progress * animation_player.current_animation_length)
	
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)


func steal(seconds:float) -> float:
	if is_hovered and animation_player.current_animation_position > 0.0:
		animation_player.advance(-seconds)
		return seconds
	return 0.0


func give(seconds:float) -> float:
	if is_hovered and animation_player.current_animation_position < animation_player.current_animation_length:
		animation_player.advance(seconds)
		return seconds
	return 0.0


func _on_mouse_enter() -> void:
	is_hovered = true
	sprite.set_instance_shader_parameter("is_enabled", is_hovered)


func _on_mouse_exit() -> void:
	is_hovered = false
	sprite.set_instance_shader_parameter("is_enabled", is_hovered)
