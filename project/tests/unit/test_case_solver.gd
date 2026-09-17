extends GutTest

func _load_case(path: String) -> CaseDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	var result := JSON.parse_string(file.get_as_text())
	return CaseDefinition.from_dict(result)

func test_unique_case_from_fixture():
	var solver := CaseSolver.new()
	var result := solver.validate(_load_case("res://data/cases/test_unique_case.json"))
	assert_eq(result.valid, true, result.error)
	assert_eq(result.solution_count, 1)
	assert_true(result.murderer_deterministic)

func test_apply_valid_move():
	var def := CaseDefinition.new()
	def.set_categories({"suspect": ["A", "B"], "room": ["X", "Y"]})
	var state := CaseState.new(def)
	var solver := CaseSolver.new()
	var move := CaseSolver.GridMove.new("suspect", "A", "room", "X", CaseDefinition.CellState.CONFIRMED)
	var result := solver.apply(state, move)
	assert_true(result.accepted)

func test_apply_contradiction():
	var def := CaseDefinition.new()
	def.set_categories({"suspect": ["A", "B"], "room": ["X", "Y"]})
	var state := CaseState.new(def)
	var solver := CaseSolver.new()
	solver.apply(state, CaseSolver.GridMove.new("suspect", "A", "room", "X", CaseDefinition.CellState.CONFIRMED))
	var result := solver.apply(state, CaseSolver.GridMove.new("suspect", "B", "room", "X", CaseDefinition.CellState.CONFIRMED))
	assert_true(result.contradiction)

func test_mansion_case_is_unique():
	var solver := CaseSolver.new()
	var result := solver.validate(_load_case("res://data/cases/mansion_case.json"))
	assert_true(result.valid, result.error)
	assert_eq(result.solution_count, 1)
	assert_true(result.murderer_deterministic)
