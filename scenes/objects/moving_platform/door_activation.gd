extends Area2D

@export var door:PlatformPath

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	door.pause()

func _on_body_entered(body:Node2D):
	if body is Player:
		door.unpause()
		
		
