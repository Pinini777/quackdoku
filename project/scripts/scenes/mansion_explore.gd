extends Node
class_name MansionExplore

const DIALOGUE_PATH := "res://data/dialogue/mansion.json"
const CASE_PATH := "res://data/cases/mansion_case.json"

var case_definition: CaseDefinition
var dialogue: Dictionary = {}
var revealed_clue_count: int = 0

func _ready() -> void:
	_load()

func _load() -> void:
	_load_case()
	_load_dialogue()

func _load_case() -> void:
	var file := FileAccess.open(CASE_PATH, FileAccess.READ)
	if file == null:
		push_error("Mansion case missing")
		return
	var parsed := JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("Mansion case invalid")
		return
	case_definition = CaseDefinition.from_dict(parsed)

func _load_dialogue() -> void:
	var file := FileAccess.open(DIALOGUE_PATH, FileAccess.READ)
	if file == null:
		push_error("Mansion dialogue missing")
		return
	var parsed := JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("Mansion dialogue invalid")
		return
	dialogue = parsed
	revealed_clue_count = 0

func total_clues() -> int:
	return dialogue.get("clues", []).size()

func reveal_next_clue() -> String:
	var clues := dialogue.get("clues", []) as Array
	if revealed_clue_count >= clues.size():
		return ""
	var text := clues[revealed_clue_count] as String
	revealed_clue_count += 1
	return text

func start_case_board() -> void:
	SceneRouter.goto("case_board")

func ending_text() -> Dictionary:
	return dialogue.get("ending", {})
