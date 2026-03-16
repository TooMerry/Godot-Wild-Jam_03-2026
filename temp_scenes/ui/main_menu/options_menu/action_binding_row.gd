class_name ActionBindingRow
extends Control

signal rebind_requested(row: ActionBindingRow)

@export var label: Label
@export var button: Button

var action_name: StringName


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)


func setup(action: StringName) -> void:
	action_name = action
	label.text = action_name.to_upper()
	
	update_button_text()


func update_button_text() -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	if events.is_empty():
		return
	
	var event_text: String = events[0].as_text()
	button.text = event_text
	button.tooltip_text = event_text


func make_button_grab_focus() -> void:
	button.grab_focus()


func _on_button_pressed() -> void:
	button.text = "..."
	rebind_requested.emit(self)
