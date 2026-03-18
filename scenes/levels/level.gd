class_name Level
extends Node

@export var level_id: int = 0
@export var next_level_id: int = 0
@export var next_level_path: String

@export var initial_timer: float = 60.0

@export var animation_player: AnimationPlayer
@export var exit_area: Area2D


func _ready() -> void:
	exit_area.body_entered.connect(_on_exit_area_entered)
	
	await SceneManager.transition_finished
	animation_player.play(&"intro")
	await animation_player.animation_finished
	
	PlayerStats.set_time(initial_timer)
	PlayerStats.paused = false


func go_to_next_level() -> void:
	SceneManager.change_scene(next_level_path)


func _on_exit_area_entered(_body: Node2D) -> void:
	PlayerStats.paused = true
	SaveManager.unlock_level(next_level_id)
	go_to_next_level()
