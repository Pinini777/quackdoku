class_name CaseDefinition
extends RefCounted

enum Operator { EQUALS, NOT_EQUALS, BEFORE, ADJACENT }
enum CellState { UNKNOWN, EXCLUDED, CONFIRMED }

class Constraint extends RefCounted:
	var category_a: String
	var value_a: String
	var op: int
	var category_b: String
	var value_b: String

	func _init(ca: String, va: String, operator_: int, cb: String, vb: String) -> void:
		category_a = ca
		value_a = va
		op = operator_
		category_b = cb
		value_b = vb

	func to_dict() -> Dictionary:
		return {"category_a": category_a, "value_a": value_a, "op": op, "category_b": category_b, "value_b": value_b}

	static func from_dict(d: Dictionary) -> Constraint:
		return Constraint.new(d.category_a, d.value_a, d.op, d.category_b, d.value_b)

var title: String = ""
var version: String = "1"
var categories: Dictionary = {}
var constraints: Array = []
var murderer_category: String = ""
var murderer_value: String = ""

func set_categories(cats: Dictionary) -> void:
	categories = cats

func add_constraint(c: Constraint) -> void:
	constraints.append(c)

func to_dict() -> Dictionary:
	return {
		"title": title,
		"version": version,
		"categories": categories,
		"constraints": constraints.map(func(c): return c.to_dict()),
		"murderer_category": murderer_category,
		"murderer_value": murderer_value,
	}

static func from_dict(d: Dictionary) -> CaseDefinition:
	var def := CaseDefinition.new()
	def.title = d.get("title", "")
	def.version = d.get("version", "1")
	def.categories = d.get("categories", {})
	for c in d.get("constraints", []):
		def.add_constraint(Constraint.from_dict(c))
	def.murderer_category = d.get("murderer_category", "")
	def.murderer_value = d.get("murderer_value", "")
	return def
