extends Node

const SAVE_DIR := "user://saves/"
const SLOT := "slot0.json"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func path() -> String:
	return SAVE_DIR + SLOT


func write_slot(payload: Dictionary) -> void:
	var file := FileAccess.open(path(), FileAccess.WRITE)
	if file == null:
		push_error("Save failed: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(payload, "\t"))


func read_slot() -> Dictionary:
	if not FileAccess.file_exists(path()):
		return {}
	var file := FileAccess.open(path(), FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed
