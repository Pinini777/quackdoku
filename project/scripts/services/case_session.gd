extends Node
class_name CaseSession

const CASE_PATH := "res://data/cases/mansion_case.json"
const DIALOGUE_PATH := "res://data/dialogue/mansion.json"

signal state_changed
signal feedback(message: String)
signal accusation_unlocked
signal case_completed
signal clue_count_changed(count: int)

var case_definition: CaseDefinition
var case_state: CaseState
var case_solver := CaseSolver.new()
var save_repository := SaveRepository.new()

var revealed_clue_count: int = 0
var accused_suspect: String = ""
var completed: bool = false
var collectible_id: String = ""

var _dialogue: Dictionary = {}


func _ready() -> void:
	_load_case_definition()
	_load_dialogue()


func _load_case_definition() -> bool:
	var file := FileAccess.open(CASE_PATH, FileAccess.READ)
	if file == null:
		push_error("Case file missing: %s" % CASE_PATH)
		return false
	var parsed := JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("Case file invalid JSON")
		return false
	case_definition = CaseDefinition.from_dict(parsed)
	return true


func _load_dialogue() -> bool:
	var file := FileAccess.open(DIALOGUE_PATH, FileAccess.READ)
	if file == null:
		push_error("Dialogue file missing: %s" % DIALOGUE_PATH)
		return false
	var parsed := JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("Dialogue file invalid JSON")
		return false
	_dialogue = parsed
	return true


func start_case(pre_revealed_clues: int = 0) -> Error:
	if case_definition == null and not _load_case_definition():
		return ERR_CANT_OPEN
	if _dialogue.is_empty():
		_load_dialogue()

	var validation := case_solver.validate(case_definition)
	if not validation.valid:
		push_error("Case is not playable: %s" % validation.error)
		return ERR_INVALID_DATA

	case_state = CaseState.new(case_definition)
	revealed_clue_count = clampi(pre_revealed_clues, 0, total_clues())
	accused_suspect = ""
	completed = false
	collectible_id = ""
	_save_progress("case_board")
	state_changed.emit()
	clue_count_changed.emit(revealed_clue_count)
	return OK


func total_clues() -> int:
	return _dialogue.get("clues", []).size()


func clue_text(index: int) -> String:
	var clues := _dialogue.get("clues", []) as Array
	if index < 0 or index >= clues.size():
		return ""
	return clues[index]


func revealed_clues() -> Array:
	return (_dialogue.get("clues", []) as Array).slice(0, revealed_clue_count)


func apply_move(category_a: String, value_a: String, category_b: String, value_b: String, state: int) -> bool:
	if case_state == null:
		feedback.emit("No active case.")
		return false

	var move := CaseSolver.GridMove.new(category_a, value_a, category_b, value_b, state)
	var result := case_solver.apply(case_state, move)
	if result.accepted:
		_save_progress("case_board")
		state_changed.emit()
		if is_accusation_unlocked():
			accusation_unlocked.emit()
		return true
	else:
		feedback.emit(_narrative_error(result.message))
		return false


func undo_last_move() -> void:
	if case_state == null:
		return
	case_state.undo()
	_save_progress("case_board")
	state_changed.emit()


func is_accusation_unlocked() -> bool:
	if case_state == null:
		return false
	return case_state.is_complete()


func accuse(suspect: String) -> bool:
	if not is_accusation_unlocked():
		feedback.emit("The board is not complete yet.")
		return false

	var murderer := _murderer_suspect()
	if murderer.is_empty():
		feedback.emit("The facts do not point to anyone yet.")
		return false

	accused_suspect = suspect
	if accused_suspect != murderer:
		feedback.emit(_narrative_error("That suspect does not match the evidence."))
		return false

	completed = true
	collectible_id = ending_data().get("collectible", {}).get("id", "")
	_save_progress("ending")
	case_completed.emit()
	return true


func _murderer_suspect() -> String:
	if case_definition.murderer_category == "suspect":
		return case_definition.murderer_value
	for suspect in case_definition.categories.get("suspect", []):
		if case_state.get_cell("suspect", suspect, case_definition.murderer_category, case_definition.murderer_value) == CaseDefinition.CellState.CONFIRMED:
			return suspect
	return ""


func ending_data() -> Dictionary:
	var base := _dialogue.get("ending", {}) as Dictionary
	var data := base.duplicate(true)
	data["accused_suspect"] = accused_suspect
	return data


func _narrative_error(fallback: String) -> String:
	var errors := _dialogue.get("errors", []) as Array
	if errors.is_empty():
		return fallback
	return errors[randi() % errors.size()]


func _save_progress(step: String) -> void:
	if case_definition == null or case_state == null:
		return
	var state_dict := case_state.to_dict()
	var snapshot := {
		"case_version": case_definition.version,
		"flow_step": step,
		"revealed_clue_count": revealed_clue_count,
		"matrices": state_dict.get("matrices", {}),
		"history": state_dict.get("history", []),
		"accused_suspect": accused_suspect,
		"completed": completed,
		"collectible_id": collectible_id,
	}
	var err := save_repository.save(snapshot)
	if err != OK:
		push_warning("Failed to save progress: %d" % err)


func has_saved_progress() -> bool:
	return FileAccess.file_exists(SaveRepository.SAVE_PATH)


func load_progress() -> bool:
	if case_definition == null and not _load_case_definition():
		return false
	var snapshot := save_repository.load_valid(case_definition.version)
	if snapshot.is_empty():
		return false
	case_state = CaseState.new(case_definition)
	case_state.from_dict(snapshot)
	revealed_clue_count = snapshot.get("revealed_clue_count", 0)
	accused_suspect = snapshot.get("accused_suspect", "")
	completed = snapshot.get("completed", false)
	collectible_id = snapshot.get("collectible_id", "")
	state_changed.emit()
	clue_count_changed.emit(revealed_clue_count)
	return true


func discard_progress() -> void:
	save_repository.discard()
