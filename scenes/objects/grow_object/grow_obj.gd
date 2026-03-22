@tool
class_name GrowObj
extends Stealable

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
@export var _time_transfer_multiplier = 1.:
	set(value):
		time_transfer_multiplier = value

func _ready() -> void:
	animation_player.play(&"grow")
	animation_player.pause()
	animation_player.advance(initial_progress * animation_player.current_animation_length)


func steal(seconds:float) -> float:
	seconds*=time_transfer_multiplier
	if animation_player.current_animation_position > 0.0:
		animation_player.advance(-seconds)
		return seconds
	return 0.0


func give(seconds:float) -> float:
	seconds*=time_transfer_multiplier
	if animation_player.current_animation_position < animation_player.current_animation_length:
		animation_player.advance(seconds)
		return seconds
	return 0.0


func set_highlight(enabled: bool) -> void:
	sprite.set_instance_shader_parameter("is_enabled", enabled)
