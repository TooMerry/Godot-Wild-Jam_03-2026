extends Node

const OPTIONS_FILE: String = "user://options.cfg"

const SECTION_AUDIO: String = "audio"
const SECTION_KEY_MASTER_VOLUME: String = "master_volume"

const SECTION_CONTROLS: String = "controls"

@export_range(0.0, 1.0, 0.01) var default_master_volume: float = 0.2

var options: ConfigFile = ConfigFile.new()


func _ready() -> void:
	initialize_options()


func initialize_options() -> void:
	options.clear()
	
	if not FileAccess.file_exists(OPTIONS_FILE):
		create_options()
		return
	
	load_options()


func create_options() -> void:
	AudioServer.set_bus_volume_linear(0, default_master_volume)
	save_options()


func load_options() -> void:
	options.load(OPTIONS_FILE)
	load_audio()
	load_controls()


func load_audio() -> void:
	if not options.has_section(SECTION_AUDIO):
		return
	
	var master_volume: float = options.get_value(SECTION_AUDIO, SECTION_KEY_MASTER_VOLUME, default_master_volume)
	AudioServer.set_bus_volume_linear(0, master_volume)


func load_controls() -> void:
	if not options.has_section(SECTION_CONTROLS):
		return
	
	var section_keys: PackedStringArray = options.get_section_keys(SECTION_CONTROLS)
	for action: StringName in InputMap.get_actions():
		if not section_keys.has(action):
			continue
		
		InputMap.action_erase_events(action)
		var event: InputEvent = options.get_value(SECTION_CONTROLS, action)
		InputMap.action_add_event(action, event)


func save_options() -> void:
	save_audio()
	save_controls()
	options.save(OPTIONS_FILE)


func save_audio() -> void:
	var master_volume: float = AudioServer.get_bus_volume_linear(0)
	options.set_value(SECTION_AUDIO, SECTION_KEY_MASTER_VOLUME, master_volume)


func save_controls() -> void:
	for action: StringName in InputMap.get_actions():
		if action.begins_with("ui"):
			continue
		
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if events.is_empty():
			continue
		
		options.set_value(SECTION_CONTROLS, action, events[0])
