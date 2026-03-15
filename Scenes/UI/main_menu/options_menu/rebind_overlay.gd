class_name RebindOverlay
extends Control

signal rebind_cancelled
signal rebind_finished(event: InputEvent)

@export var cancel_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_focus_mode(Control.FOCUS_ALL)
	set_mouse_filter(Control.MOUSE_FILTER_STOP)
	set_process_mode(Node.PROCESS_MODE_DISABLED)
	hide()
	
	cancel_button.pressed.connect(cancel)


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_pressed():
		if event is InputEventKey \
			or event is InputEventMouseButton \
			or event is InputEventJoypadButton:
			get_viewport().set_input_as_handled()
			finish(event)


func start_capture() -> void:
	if visible:
		return
	
	show()
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	grab_focus()


func cancel() -> void:
	if not visible:
		return
	
	reset()
	rebind_cancelled.emit()


func finish(event: InputEvent) -> void:
	if not visible:
		return
	
	reset()
	rebind_finished.emit(event)


func reset() -> void:
	release_focus()
	set_process_mode(Node.PROCESS_MODE_DISABLED)
	hide()
