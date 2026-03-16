class_name OptionsMenu
extends RightSideMenu

@export var actions: Array[StringName] = []
@export var actions_container: Control
@export var action_binding_row_scene: PackedScene
@export var rebind_overlay: RebindOverlay

var _current_rebinding_row: ActionBindingRow

@onready var _tree_root: Window = get_tree().root


func _ready() -> void:
	super._ready()
	
	rebind_overlay.rebind_cancelled.connect(_on_rebind_cancelled)
	rebind_overlay.rebind_finished.connect(_on_rebind_finished)
	
	for action: StringName in actions:
		var action_binding_row: ActionBindingRow = action_binding_row_scene.instantiate()
		action_binding_row.setup(action)
		action_binding_row.rebind_requested.connect(_on_rebind_requested)
		actions_container.add_child(action_binding_row)


func reset() -> void:
	super.reset()
	OptionsManager.save_options()


func _on_rebind_requested(row: ActionBindingRow) -> void:
	if _current_rebinding_row != null:
		return
	
	rebind_overlay.reparent(_tree_root, false)
	_current_rebinding_row = row
	rebind_overlay.start_capture()


func _on_rebind_cancelled() -> void:
	if _current_rebinding_row == null:
		return
	
	_current_rebinding_row.update_button_text()
	_current_rebinding_row.make_button_grab_focus()
	_current_rebinding_row = null
	rebind_overlay.reparent(self, false)


func _on_rebind_finished(event: InputEvent) -> void:
	if _current_rebinding_row == null:
		return
	
	var action_name: StringName = _current_rebinding_row.action_name
	if InputMap.has_action(action_name):
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)
	
	_current_rebinding_row.update_button_text()
	_current_rebinding_row.make_button_grab_focus()
	_current_rebinding_row = null
	rebind_overlay.reparent(self, false)
