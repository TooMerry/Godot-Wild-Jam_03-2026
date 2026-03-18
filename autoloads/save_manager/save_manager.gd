extends Node

const SAVE_FILE: String = "user://save.json"

const KEY_UNLOCKED_LEVELS: String = "unlocked_levels"

var unlocked_levels: Array[int] = [0]


func _ready() -> void:
	load_data()


func load_data() -> void:
	var json_string: String = FileAccess.get_file_as_string(SAVE_FILE)
	if json_string.is_empty():
		save_data()
		return
	
	var raw_data: Variant = JSON.parse_string(json_string)
	if raw_data == null or raw_data is not Dictionary:
		save_data()
		return
	
	var data: Dictionary = raw_data
	if KEY_UNLOCKED_LEVELS in data and data[KEY_UNLOCKED_LEVELS] is Array:
		unlocked_levels.clear()
		for element: Variant in data[KEY_UNLOCKED_LEVELS]:
			if element is float:
				unlocked_levels.push_back(element)
		
		if unlocked_levels.is_empty():
			unlocked_levels = [0]


func save_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null:
		return
	
	var data: Dictionary = { KEY_UNLOCKED_LEVELS: unlocked_levels }
	var json_string: String = JSON.stringify(data, "\t")
	file.store_string(json_string)


func unlock_level(id: int) -> void:
	if unlocked_levels.has(id):
		return
	
	unlocked_levels.push_back(id)
	save_data()
