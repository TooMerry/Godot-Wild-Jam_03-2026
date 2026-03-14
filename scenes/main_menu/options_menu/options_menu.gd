class_name OptionsMenu
extends RightSideMenu

@export var actions: Array[StringName] = []
@export var actions_container: Control
@export var rebind_overlay_scene: PackedScene
@export var action_binding_row_scene: PackedScene

var rebind_overlay: RebindOverlay
var current_rebinding_row: ActionBindingRow


func _ready() -> void:
	super._ready()
	
	rebind_overlay = rebind_overlay_scene.instantiate()
	get_tree().root.add_child.call_deferred(rebind_overlay)
	rebind_overlay.rebind_cancelled.connect(_on_rebind_cancelled)
	rebind_overlay.rebind_finished.connect(_on_rebind_finished)
	
	for action in actions:
		var action_binding_row: ActionBindingRow = action_binding_row_scene.instantiate()
		action_binding_row.setup(action)
		action_binding_row.rebind_requested.connect(_on_rebind_requested)
		actions_container.add_child(action_binding_row)


func _on_rebind_requested(row: ActionBindingRow) -> void:
	if current_rebinding_row != null:
		return
	
	current_rebinding_row = row
	rebind_overlay.start_capture()


func _on_rebind_cancelled() -> void:
	if current_rebinding_row == null:
		return
	
	current_rebinding_row.update_button_text()
	current_rebinding_row.make_button_grab_focus()
	current_rebinding_row = null


func _on_rebind_finished(event: InputEvent) -> void:
	if current_rebinding_row == null:
		return
	
	var action_name: StringName = current_rebinding_row.action_name
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	current_rebinding_row.update_button_text()
	current_rebinding_row.make_button_grab_focus()
	current_rebinding_row = null
