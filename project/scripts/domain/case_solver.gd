class_name CaseSolver
extends RefCounted

class ValidationResult extends RefCounted:
	var valid: bool = false
	var solution_count: int = 0
	var murderer_deterministic: bool = false
	var error: String = ""

class MoveResult extends RefCounted:
	var accepted: bool = false
	var contradiction: bool = false
	var message: String = ""

class GridMove extends RefCounted:
	var category_a: String
	var value_a: String
	var category_b: String
	var value_b: String
	var state: int

	func _init(ca: String, va: String, cb: String, vb: String, s: int) -> void:
		category_a = ca; value_a = va; category_b = cb; value_b = vb; state = s

func validate(definition: CaseDefinition) -> ValidationResult:
	var res := ValidationResult.new()
	var suspects: Array = definition.categories.get("suspect", [])
	var cats := definition.categories.duplicate()
	cats.erase("suspect")
	if suspects.is_empty() or cats.is_empty():
		res.error = "Missing categories"
		return res
	var solutions := []
	_solve({}, suspects, cats, definition, solutions, 2)
	res.solution_count = solutions.size()
	res.valid = res.solution_count == 1
	if res.valid:
		var murderer := _murderer_for(solutions[0], definition)
		var category_values: Array = definition.categories.get(definition.murderer_category, [])
		res.murderer_deterministic = not murderer.is_empty() and definition.murderer_value in category_values
	else:
		res.error = "Expected exactly one solution, found %d" % res.solution_count
	return res

func _solve(assignment: Dictionary, suspects: Array, categories: Dictionary, definition: CaseDefinition, solutions: Array, limit: int) -> void:
	if solutions.size() > limit:
		return
	var idx := assignment.size()
	if idx >= suspects.size():
		if _satisfies(assignment, definition):
			solutions.append(assignment.duplicate(true))
		return
	var s := suspects[idx]
	for combo in _options(categories):
		if _combo_used(combo, assignment):
			continue
		assignment[s] = combo
		if _partial_ok(assignment, definition):
			_solve(assignment, suspects, categories, definition, solutions, limit)
		assignment.erase(s)

func _options(categories: Dictionary) -> Array:
	var keys := categories.keys()
	if keys.is_empty():
		return []
	var first := categories[keys[0]]
	if keys.size() == 1:
		var out := []
		for v in first:
			out.append({keys[0]: v})
		return out
	var rest := categories.duplicate()
	rest.erase(keys[0])
	var result := []
	for v in first:
		for tail in _options(rest):
			var combo := {keys[0]: v}
			combo.merge(tail)
			result.append(combo)
	return result

func _combo_used(combo: Dictionary, assignment: Dictionary) -> bool:
	for cat in combo:
		var value := combo[cat]
		for s in assignment:
			if assignment[s].get(cat) == value:
				return true
	return false

func _satisfies(assignment: Dictionary, definition: CaseDefinition) -> bool:
	return _partial_ok(assignment, definition)

func _partial_ok(assignment: Dictionary, definition: CaseDefinition) -> bool:
	for c in definition.constraints:
		var a := _resolve(c.category_a, c.value_a, assignment)
		var b := _resolve(c.category_b, c.value_b, assignment)
		if not _check_constraint(c.op, a, b, definition):
			return false
	return true

func _resolve(category: String, value: String, assignment: Dictionary) -> Dictionary:
	if category == "suspect":
		return {"suspect": value, "attrs": assignment.get(value, {})}
	for s in assignment:
		if assignment[s].get(category) == value:
			return {"suspect": s, "attrs": assignment[s]}
	return {}

func _check_constraint(op: int, a: Dictionary, b: Dictionary, definition: CaseDefinition) -> bool:
	if a.is_empty() or b.is_empty():
		return true
	if a.get("attrs", {}).is_empty() or b.get("attrs", {}).is_empty():
		return true
	match op:
		CaseDefinition.Operator.EQUALS:
			return a.suspect == b.suspect
		CaseDefinition.Operator.NOT_EQUALS:
			return a.suspect != b.suspect
		CaseDefinition.Operator.BEFORE, CaseDefinition.Operator.ADJACENT:
			var ta := definition.categories["time"].find(a.attrs.get("time", ""))
			var tb := definition.categories["time"].find(b.attrs.get("time", ""))
			if ta < 0 or tb < 0:
				return true
			if op == CaseDefinition.Operator.BEFORE:
				return ta < tb
			return abs(ta - tb) == 1
	return true

func _murderer_for(assignment: Dictionary, definition: CaseDefinition) -> String:
	if definition.murderer_category == "suspect":
		return definition.murderer_value
	for s in assignment:
		if assignment[s].get(definition.murderer_category) == definition.murderer_value:
			return s
	return ""

func apply(state: CaseState, move: GridMove) -> MoveResult:
	var res := MoveResult.new()
	var current := state.get_cell(move.category_a, move.value_a, move.category_b, move.value_b)
	if current != CaseDefinition.CellState.UNKNOWN and current != move.state:
		res.contradiction = true
		res.message = "Cell already marked differently"
		return res
	var snapshot := state.to_dict()
	state.set_cell(move.category_a, move.value_a, move.category_b, move.value_b, move.state)
	state.end_operation()
	if _state_contradicts(state):
		state.from_dict(snapshot)
		res.contradiction = true
		res.message = "Move creates a contradiction"
		return res
	res.accepted = true
	return res

func _state_contradicts(state: CaseState) -> bool:
	var cats := state.definition.categories.keys()
	cats.sort()
	for i in range(cats.size()):
		for j in range(i + 1, cats.size()):
			var ca := cats[i]; var cb := cats[j]
			for a in state.definition.categories[ca]:
				var count := 0
				for b in state.definition.categories[cb]:
					if state.get_cell(ca, a, cb, b) == CaseDefinition.CellState.CONFIRMED:
						count += 1
				if count > 1:
					return true
			for b in state.definition.categories[cb]:
				var count := 0
				for a in state.definition.categories[ca]:
					if state.get_cell(ca, a, cb, b) == CaseDefinition.CellState.CONFIRMED:
						count += 1
				if count > 1:
					return true
	return false
