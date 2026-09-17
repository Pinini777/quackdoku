extends GutTest

func _make_def() -> CaseDefinition:
	var def := CaseDefinition.new()
	def.set_categories({"suspect": ["A", "B"], "room": ["X", "Y"]})
	return def

func test_initial_state_unknown():
	var state := CaseState.new(_make_def())
	assert_eq(state.get_cell("suspect", "A", "room", "X"), CaseDefinition.CellState.UNKNOWN)

func test_confirm_and_propagate():
	var state := CaseState.new(_make_def())
	state.set_cell("suspect", "A", "room", "X", CaseDefinition.CellState.CONFIRMED)
	assert_eq(state.get_cell("suspect", "A", "room", "Y"), CaseDefinition.CellState.EXCLUDED)
	assert_eq(state.get_cell("suspect", "B", "room", "X"), CaseDefinition.CellState.EXCLUDED)

func test_undo():
	var state := CaseState.new(_make_def())
	state.set_cell("suspect", "A", "room", "X", CaseDefinition.CellState.CONFIRMED)
	state.undo()
	assert_eq(state.get_cell("suspect", "A", "room", "X"), CaseDefinition.CellState.UNKNOWN)

func test_apply_constraint():
	var state := CaseState.new(_make_def())
	var c := CaseDefinition.Constraint.new("suspect", "A", CaseDefinition.Operator.NOT_EQUALS, "room", "Y")
	state.apply_constraint(c)
	assert_eq(state.get_cell("suspect", "A", "room", "Y"), CaseDefinition.CellState.EXCLUDED)
