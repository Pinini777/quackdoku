class_name CaseState
extends RefCounted

const UNKNOWN := CaseDefinition.CellState.UNKNOWN
const EXCLUDED := CaseDefinition.CellState.EXCLUDED
const CONFIRMED := CaseDefinition.CellState.CONFIRMED

var definition: CaseDefinition
var matrices: Dictionary = {}
var history: Array = []
var _in_op: bool = false

func _init(def: CaseDefinition) -> void:
	definition = def
	_clear_matrices()

func _clear_matrices() -> void:
	matrices.clear()
	var cats := definition.categories.keys()
	cats.sort()
	for i in range(cats.size()):
		for j in range(i + 1, cats.size()):
			var key := "%s|%s" % [cats[i], cats[j]]
			matrices[key] = {}
			for a in definition.categories[cats[i]]:
				for b in definition.categories[cats[j]]:
					matrices[key]["%s|%s" % [a, b]] = UNKNOWN

func _pair_key(cat_a: String, cat_b: String) -> String:
	return "%s|%s" % [cat_a, cat_b] if cat_a < cat_b else "%s|%s" % [cat_b, cat_a]

func get_cell(cat_a: String, val_a: String, cat_b: String, val_b: String) -> int:
	var key := _pair_key(cat_a, cat_b)
	var vals := "%s|%s" % [val_a, val_b] if cat_a < cat_b else "%s|%s" % [val_b, val_a]
	return matrices.get(key, {}).get(vals, UNKNOWN)

func set_cell(cat_a: String, val_a: String, cat_b: String, val_b: String, state: int) -> void:
	var key := _pair_key(cat_a, cat_b)
	var vals := "%s|%s" % [val_a, val_b] if cat_a < cat_b else "%s|%s" % [val_b, val_a]
	if not matrices.has(key) or not matrices[key].has(vals):
		return
	if matrices[key][vals] == state:
		return
	if not _in_op:
		history.append({"type": "snapshot", "matrices": _clone_matrices()})
		_in_op = true
	matrices[key][vals] = state
	if state == CONFIRMED:
		_propagate(cat_a, val_a, cat_b, val_b)

func _clone_matrices() -> Dictionary:
	var clone := {}
	for k in matrices:
		clone[k] = matrices[k].duplicate()
	return clone

func _propagate(cat_a: String, val_a: String, cat_b: String, val_b: String) -> void:
	for other in definition.categories[cat_a]:
		if other != val_a and get_cell(cat_a, other, cat_b, val_b) == UNKNOWN:
			set_cell(cat_a, other, cat_b, val_b, EXCLUDED)
	for other in definition.categories[cat_b]:
		if other != val_b and get_cell(cat_a, val_a, cat_b, other) == UNKNOWN:
			set_cell(cat_a, val_a, cat_b, other, EXCLUDED)

func apply_constraint(c: CaseDefinition.Constraint) -> bool:
	match c.op:
		CaseDefinition.Operator.EQUALS:
			set_cell(c.category_a, c.value_a, c.category_b, c.value_b, CONFIRMED)
		CaseDefinition.Operator.NOT_EQUALS:
			set_cell(c.category_a, c.value_a, c.category_b, c.value_b, EXCLUDED)
	end_operation()
	return true

func end_operation() -> void:
	_in_op = false

func undo() -> void:
	if history.is_empty():
		return
	var last := history.pop_back()
	if last.type == "snapshot":
		matrices = _dict_clone(last.matrices)
	_in_op = false

func _dict_clone(d: Dictionary) -> Dictionary:
	var clone := {}
	for k in d:
		clone[k] = d[k].duplicate()
	return clone

func is_complete() -> bool:
	for key in matrices:
		for vals in matrices[key]:
			if matrices[key][vals] == UNKNOWN:
				return false
	return true

func to_dict() -> Dictionary:
	return {"matrices": _clone_matrices(), "history": history.duplicate(true)}

func from_dict(d: Dictionary) -> void:
	matrices = _dict_clone(d.get("matrices", {}))
	history = d.get("history", []).duplicate(true)
