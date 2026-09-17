extends Node
class_name Tutorial

const DATA_PATH := "res://data/dialogue/tutorial.json"

var data: Dictionary = {}
var current_step_index: int = -1
var completed: bool = false

func _ready() -> void:
	_load()

func _load() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Tutorial data missing")
		return
	var parsed := JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("Tutorial data invalid")
		return
	data = parsed
	current_step_index = -1
	completed = false

func start() -> void:
	current_step_index = 0 if data.get("steps", []).size() > 0 else -1
	completed = false

func current_step() -> Dictionary:
	var steps := data.get("steps", []) as Array
	if current_step_index < 0 or current_step_index >= steps.size():
		return {}
	return steps[current_step_index]

func advance() -> bool:
	if completed:
		return false
	var steps := data.get("steps", []) as Array
	current_step_index += 1
	if current_step_index >= steps.size():
		_complete()
		return false
	return true

func skip_available(elapsed_seconds: float) -> bool:
	return data.get("allow_skip", false) and elapsed_seconds >= data.get("max_seconds", 300)

func is_complete() -> bool:
	return completed

func practice_case() -> CaseDefinition:
	return CaseDefinition.from_dict(data.get("practice_case", {}))

func _complete() -> void:
	completed = true
	var next_scene := data.get("complete_transition", "mansion_explore") as String
	SceneRouter.goto(next_scene)
