extends GutTest

func test_categories_and_operators():
	var def := CaseDefinition.new()
	def.set_categories({"suspect": ["A", "B"], "room": ["X", "Y"]})
	assert_eq(def.categories["suspect"].size(), 2)
	def.add_constraint(CaseDefinition.Constraint.new("suspect", "A", CaseDefinition.Operator.EQUALS, "room", "X"))
	def.add_constraint(CaseDefinition.Constraint.new("suspect", "B", CaseDefinition.Operator.NOT_EQUALS, "room", "Y"))
	assert_eq(def.constraints.size(), 2)

func test_serialization():
	var def := CaseDefinition.new()
	def.title = "T"
	def.version = "2"
	def.set_categories({"suspect": ["A"], "room": ["X"]})
	def.add_constraint(CaseDefinition.Constraint.new("suspect", "A", CaseDefinition.Operator.EQUALS, "room", "X"))
	var copy := CaseDefinition.from_dict(def.to_dict())
	assert_eq(copy.title, "T")
	assert_eq(copy.version, "2")
	assert_eq(copy.constraints.size(), 1)
