extends Node
## Global game settings manager.
##
## This class handles saving and loading configuration options such as
## audio levels and input controls.[br]
## It should be registered as an Autoload so it can be accessed globally.[br]
## It uses [ConfigFile] to persist settings to [constant OPTIONS_FILE]
## ([code]user://options.cfg[/code]).[br]
## [br]
## Usage example:
## [codeblock]
## # Save the current options to disk
## OptionsManager.save_options()
##
## # Load saved options from disk
## OptionsManager.load_options()
## [/codeblock]

const OPTIONS_FILE: String = "user://options.cfg"

const SECTION_GAMEPLAY: String = "gameplay"
const SECTION_KEY_LOCALE: String = "locale"

const SECTION_AUDIO: String = "audio"
const SECTION_KEY_MASTER_VOLUME: String = "master_volume"
const SECTION_KEY_BGM_VOLUME: String = "bgm_volume"
const SECTION_KEY_SFX_VOLUME: String = "sfx_volume"

const SECTION_CONTROLS: String = "controls"

@export_range(0.0, 1.0, 0.01) var default_master_volume: float = 0.2
@export_range(0.0, 1.0, 0.01) var default_bgm_volume: float = 1.0
@export_range(0.0, 1.0, 0.01) var default_sfx_volume: float = 1.0

var _options: ConfigFile = ConfigFile.new()

var _master_bus_index: int = AudioServer.get_bus_index("Master")
var _bgm_bus_index: int = AudioServer.get_bus_index("Bgm")
var _sfx_bus_index: int = AudioServer.get_bus_index("Sfx")


func _ready() -> void:
	_init_options()


func _init_options() -> void:
	_options.clear()
	
	if not FileAccess.file_exists(OPTIONS_FILE):
		_create_options()
		return
	
	load_options()


func _create_options() -> void:
	AudioServer.set_bus_volume_linear(_master_bus_index, default_master_volume)
	AudioServer.set_bus_volume_linear(_bgm_bus_index, default_bgm_volume)
	AudioServer.set_bus_volume_linear(_sfx_bus_index, default_sfx_volume)
	save_options()


func load_options() -> void:
	_options.load(OPTIONS_FILE)
	_load_gameplay()
	_load_audio()
	_load_controls()


func _load_gameplay() -> void:
	if not _options.has_section(SECTION_GAMEPLAY):
		return
	
	var locale: String = _options.get_value(
			SECTION_GAMEPLAY,
			SECTION_KEY_LOCALE,
			"en")
	TranslationServer.set_locale(locale)


func _load_audio() -> void:
	if not _options.has_section(SECTION_AUDIO):
		return
	
	var master_volume: float = _options.get_value(
			SECTION_AUDIO,
			SECTION_KEY_MASTER_VOLUME,
			default_master_volume)
	AudioServer.set_bus_volume_linear(_master_bus_index, master_volume)
	
	var bgm_volume: float = _options.get_value(
			SECTION_AUDIO,
			SECTION_KEY_BGM_VOLUME,
			default_bgm_volume)
	AudioServer.set_bus_volume_linear(_bgm_bus_index, bgm_volume)
	
	var sfx_volume: float = _options.get_value(
			SECTION_AUDIO,
			SECTION_KEY_SFX_VOLUME,
			default_sfx_volume)
	AudioServer.set_bus_volume_linear(_sfx_bus_index, sfx_volume)


func _load_controls() -> void:
	if not _options.has_section(SECTION_CONTROLS):
		return
	
	var section_keys: PackedStringArray = _options.get_section_keys(SECTION_CONTROLS)
	for action: StringName in InputMap.get_actions():
		if not section_keys.has(action):
			continue
		
		InputMap.action_erase_events(action)
		var event: InputEvent = _options.get_value(SECTION_CONTROLS, action)
		InputMap.action_add_event(action, event)


func save_options() -> void:
	_save_gameplay()
	_save_audio()
	_save_controls()
	_options.save(OPTIONS_FILE)


func _save_gameplay() -> void:
	var locale: String = TranslationServer.get_locale()
	_options.set_value(SECTION_GAMEPLAY, SECTION_KEY_LOCALE, locale)


func _save_audio() -> void:
	var master_volume: float = AudioServer.get_bus_volume_linear(_master_bus_index)
	_options.set_value(SECTION_AUDIO, SECTION_KEY_MASTER_VOLUME, master_volume)
	
	var bgm_volume: float = AudioServer.get_bus_volume_linear(_bgm_bus_index)
	_options.set_value(SECTION_AUDIO, SECTION_KEY_BGM_VOLUME, bgm_volume)
	
	var sfx_volume: float = AudioServer.get_bus_volume_linear(_sfx_bus_index)
	_options.set_value(SECTION_AUDIO, SECTION_KEY_SFX_VOLUME, sfx_volume)


func _save_controls() -> void:
	for action: StringName in InputMap.get_actions():
		if action.begins_with("ui"):
			continue
		
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if events.is_empty():
			continue
		
		_options.set_value(SECTION_CONTROLS, action, events[0])
