class_name GrowObj
extends AnimatableBody2D

@export var sprite: Sprite2D
@export var animation_player: AnimationPlayer

var is_hovered: bool = false


func _ready() -> void:
	animation_player.play(&"grow")
	animation_player.pause()
	
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)


func steal(seconds:float) -> float:
	if is_hovered && is_equal_approx(
			animation_player.current_animation_position,
			animation_player.current_animation_length):
		return 0.0
	
	animation_player.advance(seconds)
	return seconds


func give(seconds:float) -> float:
	if is_hovered && is_equal_approx(
			animation_player.current_animation_position,
			0.0):
		return 0.0
	
	animation_player.advance(-seconds)
	return seconds


func _on_mouse_enter() -> void:
	is_hovered = true
	sprite.set_instance_shader_parameter("is_enabled", is_hovered)


func _on_mouse_exit() -> void:
	is_hovered = false
	sprite.set_instance_shader_parameter("is_enabled", is_hovered)
