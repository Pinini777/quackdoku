class_name SaveRepository
extends RefCounted

const SAVE_PATH := "user://progress-v1.json"

func _checksum(data: String) -> String:
	return data.md5_text()

func save(snapshot: Dictionary) -> Error:
	var payload := snapshot.duplicate(true)
	payload["_checksum"] = _checksum(JSON.stringify(snapshot))
	payload["_saved_at"] = Time.get_unix_time_from_system()
	var file := FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload))
	file.close()
	var err := DirAccess.rename_absolute(SAVE_PATH + ".tmp", SAVE_PATH)
	return OK if err == OK else ERR_CANT_CREATE

func load_valid(case_version: String) -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var result := JSON.parse_string(text)
	if result == null or typeof(result) != TYPE_DICTIONARY:
		return {}
	if result.get("case_version") != case_version:
		return {}
	var stored_checksum := result.get("_checksum", "")
	var snapshot := result.duplicate(true)
	snapshot.erase("_checksum")
	snapshot.erase("_saved_at")
	if _checksum(JSON.stringify(snapshot)) != stored_checksum:
		return {}
	return snapshot

func discard() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
