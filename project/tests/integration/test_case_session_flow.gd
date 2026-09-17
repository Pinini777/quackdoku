extends GutTest

var _session: CaseSession

func before_each() -> void:
	_session = CaseSession.new()
	add_child_autofree(_session)
	_session.save_repository.discard()


func after_each() -> void:
	_session.save_repository.discard()


func test_start_case_loads_definition() -> void:
	assert_eq(_session.start_case(), OK)
	assert_not_null(_session.case_definition)
	assert_not_null(_session.case_state)
	assert_true(_session.case_solver.validate(_session.case_definition).valid)


func test_move_accepted_and_saved() -> void:
	assert_eq(_session.start_case(), OK)
	var accepted := _session.apply_move("suspect", "Sir Quacksalot", "room", "Grand Foyer", CaseDefinition.CellState.CONFIRMED)
	assert_true(accepted)
	assert_eq(_session.case_state.get_cell("suspect", "Sir Quacksalot", "room", "Grand Foyer"), CaseDefinition.CellState.CONFIRMED)
	assert_true(_session.has_saved_progress())


func test_invalid_move_rejected_with_feedback() -> void:
	assert_eq(_session.start_case(), OK)
	_session.apply_move("suspect", "Sir Quacksalot", "room", "Grand Foyer", CaseDefinition.CellState.CONFIRMED)
	var received := ""
	_session.feedback.connect(func(message): received = message)
	var accepted := _session.apply_move("suspect", "Lady Waddle", "room", "Grand Foyer", CaseDefinition.CellState.CONFIRMED)
	assert_false(accepted)
	assert_ne(received, "")


func test_accusation_locked_until_complete() -> void:
	assert_eq(_session.start_case(), OK)
	assert_false(_session.is_accusation_unlocked())
	assert_false(_session.accuse("Sir Quacksalot"))


func test_correct_accusation_completes_case() -> void:
	assert_eq(_session.start_case(), OK)
	var solution := _build_solution()
	for suspect in solution:
		var attrs: Dictionary = solution[suspect]
		for category in attrs:
			_session.apply_move("suspect", suspect, category, attrs[category], CaseDefinition.CellState.CONFIRMED)

	assert_true(_session.is_accusation_unlocked())
	var murderer := _session.case_solver._murderer_for(solution, _session.case_definition)
	assert_true(_session.accuse(murderer))
	assert_true(_session.completed)
	assert_true(_session.ending_data().has("revelation"))
	assert_true(_session.ending_data().has("collectible"))
	assert_true(_session.ending_data().has("hook"))


func _build_solution() -> Dictionary:
	return {
		"Sir Quacksalot": {"room": "Grand Foyer", "time": "8pm", "item": "Candlestick"},
		"Lady Waddle": {"room": "Kitchen", "time": "9pm", "item": "Cup"},
		"Lord Puddle": {"room": "Conservatory", "time": "10pm", "item": "Velvet Rope"},
		"Baron Billow": {"room": "Library", "time": "11pm", "item": "Poison Vial"},
		"Duchess Down": {"room": "Cellar", "time": "12am", "item": "Crowbar"},
		"Count Plucker": {"room": "Rooftop", "time": "1am", "item": "Pocket Watch"},
	}
