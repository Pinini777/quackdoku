extends Control
class_name Accusation

@onready var _session: CaseSession = get_node("/root/CaseSession")

var _selected: String = ""
var _suspect_buttons: Dictionary = {}

var _feedback: Label
var _confirm_button: Button


func _ready() -> void:
	anchors_preset = PRESET_FULL_RECT
	_build_ui()


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(PRESET_FULL_RECT, PRESET_MODE_MINSIZE, 20)
	add_child(root)

	var title := Label.new()
	title.text = "Make Your Accusation"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	root.add_child(title)

	var prompt := Label.new()
	prompt.text = "Who carried the %s?" % _session.case_definition.murderer_value
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_font_size_override("font_size", 22)
	root.add_child(prompt)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	root.add_child(grid)

	for suspect in _session.case_definition.categories.get("suspect", []):
		var button := Button.new()
		button.text = suspect
		button.custom_minimum_size = Vector2(280, 96)
		button.add_theme_font_size_override("font_size", 24)
		button.pressed.connect(_on_suspect_selected.bind(suspect))
		grid.add_child(button)
		_suspect_buttons[suspect] = button

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	root.add_child(actions)

	var back := Button.new()
	back.text = "Back to Board"
	back.custom_minimum_size = Vector2(180, 64)
	back.pressed.connect(_on_back_pressed)
	actions.add_child(back)

	_confirm_button = Button.new()
	_confirm_button.text = "Confirm Accusation"
	_confirm_button.custom_minimum_size = Vector2(240, 64)
	_confirm_button.disabled = true
	_confirm_button.pressed.connect(_on_confirm_pressed)
	actions.add_child(_confirm_button)

	_feedback = Label.new()
	_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback.add_theme_font_size_override("font_size", 20)
	_feedback.text = ""
	root.add_child(_feedback)


func _on_suspect_selected(suspect: String) -> void:
	_selected = suspect
	for name in _suspect_buttons:
		var button := _suspect_buttons[name] as Button
		button.modulate = Color.LIME_GREEN if name == suspect else Color.WHITE
	_confirm_button.disabled = false


func _on_confirm_pressed() -> void:
	if _session.accuse(_selected):
		SceneRouter.goto("ending")
	else:
		var errors := ["That doesn't fit the witness statement.", "Hmm, the timeline disagrees.", "Check the clues again, detective."]
		_feedback.text = errors[randi() % errors.size()]


func _on_back_pressed() -> void:
	SceneRouter.goto("case_board")
