extends GutTest

func _load_tutorial_data() -> Dictionary:
	var file := FileAccess.open("res://data/dialogue/tutorial.json", FileAccess.READ)
	assert_not_null(file)
	var result := JSON.parse_string(file.get_as_text())
	assert_ne(result, null)
	return result

func test_tutorial_duration_cap():
	var data := _load_tutorial_data()
	assert_true(data.get("max_seconds", INF) <= 300, "Tutorial must be completable in five minutes")

func test_tutorial_skip_allowed():
	var data := _load_tutorial_data()
	assert_true(data.get("allow_skip", false), "Tutorial must offer skip after time boundary")

func test_tutorial_gates():
	var data := _load_tutorial_data()
	var steps := data.get("steps", []) as Array
	assert_true(steps.size() > 0, "Tutorial must have steps")
	var valid_rules := ["narrative", "row", "column", "clue", "complete"]
	for step in steps:
		if step.get("type") == "gate":
			assert_true(valid_rules.has(step.get("rule", "")), "Gate rule must be recognized")

func test_tutorial_practice_case_unique():
	var data := _load_tutorial_data()
	var def := CaseDefinition.from_dict(data.get("practice_case", {}))
	var result := CaseSolver.new().validate(def)
	assert_true(result.valid, result.error)
	assert_true(result.solution_count == 1, "Practice case must have exactly one solution")
	assert_true(result.murderer_deterministic)

func test_tutorial_completes_to_mansion():
	var data := _load_tutorial_data()
	assert_true(data.get("complete_transition", "") == "mansion_explore", "Tutorial must transition to mansion explore")
