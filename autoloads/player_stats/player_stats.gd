extends Node
#Whether or not the timer is currently running
var paused:bool = false
var remaining_time:float = 617.0
signal timeout();
func add_time(seconds:float) -> void:
	remaining_time += seconds
func subtract_time(seconds:float) -> void:
	remaining_time -= seconds
func set_time(seconds:float) -> void:
	remaining_time = seconds
func _physics_process(delta: float) -> void:
	if !paused:
		if(remaining_time >= delta):
			remaining_time -= delta
		else:
			remaining_time = 0
		if(remaining_time <= 0):
			paused = true
			timeout.emit()
		
