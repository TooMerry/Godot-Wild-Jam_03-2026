extends Control
@export var label:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(_delta: float) -> void:
	label.text = "%.1fs"%PlayerStats.remaining_time
