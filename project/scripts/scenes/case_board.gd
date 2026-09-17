extends Control
class_name CaseBoard

const CELL_SIZE := 80
const HEADER_SIZE := 44

@onready var _session: CaseSession = get_node("/root/CaseSession")

var _root_box: VBoxContainer
var _category_tabs: HBoxContainer
var _grid: GridContainer
var _feedback: Label
var _accuse_button: Button
var _clue_dialog: AcceptDialog
var _undo_button: Button

var _current_category: String = ""
var _cell_buttons: Dictionary = {}
var _category_order: Array = []


func _ready() -> void:
	if _session.case_definition == null:
		_session.load_case_definition()
	_session.start_case()
	_category_order = _non_suspect_categories()
	_current_category = _category_order[0] if not _category_order.is_empty() else ""
	_build_ui()
	_connect_signals()
	_update_grid()


func _non_suspect_categories() -> Array:
	var keys := _session.case_definition.categories.keys() as Array
	keys.erase("suspect")
	keys.sort()
	return keys


func _build_ui() -> void:
	anchors_preset = PRESET_FULL_RECT
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	_root_box = VBoxContainer.new()
	_root_box.anchors_preset = PRESET_FULL_RECT
	_root_box.set_anchors_and_offsets_preset(PRESET_FULL_RECT, PRESET_MODE_MINSIZE, 20)
	add_child(_root_box)

	var title := Label.new()
	title.text = _session.case_definition.title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	_root_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Tap a cell to confirm, again to exclude, again to clear."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	_root_box.add_child(subtitle)

	_category_tabs = HBoxContainer.new()
	_category_tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	_category_tabs.add_theme_constant_override("separation", 12)
	_root_box.add_child(_category_tabs)

	for category in _category_order:
		var tab := Button.new()
		tab.text = category.capitalize()
		tab.custom_minimum_size = Vector2(120, 56)
		tab.pressed.connect(_on_category_selected.bind(category))
		_category_tabs.add_child(tab)

	var grid_panel := PanelContainer.new()
	grid_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root_box.add_child(grid_panel)

	_grid = GridContainer.new()
	_grid.columns = 1
	_grid.add_theme_constant_override("h_separation", 4)
	_grid.add_theme_constant_override("v_separation", 4)
	grid_panel.add_child(_grid)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	_root_box.add_child(actions)

	_undo_button = Button.new()
	_undo_button.text = "Undo"
	_undo_button.custom_minimum_size = Vector2(120, 64)
	_undo_button.pressed.connect(_on_undo_pressed)
	actions.add_child(_undo_button)

	var clues_button := Button.new()
	clues_button.text = "Clues"
	clues_button.custom_minimum_size = Vector2(120, 64)
	clues_button.pressed.connect(_on_clues_pressed)
	actions.add_child(clues_button)

	_accuse_button = Button.new()
	_accuse_button.text = "Accuse"
	_accuse_button.custom_minimum_size = Vector2(160, 64)
	_accuse_button.disabled = not _session.is_accusation_unlocked()
	_accuse_button.pressed.connect(_on_accuse_pressed)
	actions.add_child(_accuse_button)

	_feedback = Label.new()
	_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback.add_theme_font_size_override("font_size", 20)
	_feedback.text = ""
	_root_box.add_child(_feedback)

	_clue_dialog = AcceptDialog.new()
	_clue_dialog.title = "Clues"
	_clue_dialog.ok_button_text = "Close"
	_clue_dialog.min_size = Vector2(560, 400)
	add_child(_clue_dialog)

	_highlight_current_tab()
	_rebuild_grid()


func _connect_signals() -> void:
	_session.state_changed.connect(_update_grid)
	_session.accusation_unlocked.connect(_on_accusation_unlocked)
	_session.feedback.connect(_on_feedback)


func _on_category_selected(category: String) -> void:
	_current_category = category
	_highlight_current_tab()
	_rebuild_grid()


func _highlight_current_tab() -> void:
	for child in _category_tabs.get_children():
		var button := child as Button
		if button == null:
			continue
		button.modulate = Color.LIGHT_BLUE if button.text.to_lower() == _current_category.capitalize() else Color.WHITE


func _rebuild_grid() -> void:
	for child in _grid.get_children():
		child.queue_free()
	_cell_buttons.clear()

	if _current_category.is_empty():
		return

	var suspects: Array = _session.case_definition.categories["suspect"]
	var values: Array = _session.case_definition.categories[_current_category]

	_grid.columns = values.size() + 1

	var corner := Label.new()
	corner.custom_minimum_size = Vector2(HEADER_SIZE, HEADER_SIZE)
	_grid.add_child(corner)

	for value in values:
		var header := Label.new()
		header.text = _short_label(value)
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		header.custom_minimum_size = Vector2(CELL_SIZE, HEADER_SIZE)
		header.add_theme_font_size_override("font_size", 16)
		_grid.add_child(header)

	for suspect in suspects:
		var row_header := Label.new()
		row_header.text = _short_label(suspect)
		row_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row_header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row_header.custom_minimum_size = Vector2(HEADER_SIZE, CELL_SIZE)
		row_header.add_theme_font_size_override("font_size", 16)
		_grid.add_child(row_header)

		for value in values:
			var button := Button.new()
			button.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
			button.toggle_mode = false
			button.pressed.connect(_on_cell_pressed.bind(suspect, value))
			_grid.add_child(button)
			_cell_buttons[_cell_key(suspect, value)] = button


func _short_label(text: String) -> String:
	if text.length() <= 8:
		return text
	return text.substr(0, 7) + "."


func _cell_key(suspect: String, value: String) -> String:
	return "%s|%s" % [suspect, value]


func _on_cell_pressed(suspect: String, value: String) -> void:
	var current := _session.case_state.get_cell("suspect", suspect, _current_category, value)
	var next_state := CaseDefinition.CellState.UNKNOWN
	match current:
		CaseDefinition.CellState.UNKNOWN:
			next_state = CaseDefinition.CellState.CONFIRMED
		CaseDefinition.CellState.CONFIRMED:
			next_state = CaseDefinition.CellState.EXCLUDED
		CaseDefinition.CellState.EXCLUDED:
			next_state = CaseDefinition.CellState.UNKNOWN
	_session.apply_move("suspect", suspect, _current_category, value, next_state)


func _update_grid() -> void:
	if _session.case_state == null:
		return
	var values: Array = _session.case_definition.categories.get(_current_category, [])
	var suspects: Array = _session.case_definition.categories.get("suspect", [])
	for suspect in suspects:
		for value in values:
			var button := _cell_buttons.get(_cell_key(suspect, value)) as Button
			if button == null:
				continue
			var state := _session.case_state.get_cell("suspect", suspect, _current_category, value)
			match state:
				CaseDefinition.CellState.UNKNOWN:
					button.text = "?"
					button.modulate = Color.WHITE
				CaseDefinition.CellState.CONFIRMED:
					button.text = "Y"
					button.modulate = Color.LIME_GREEN
				CaseDefinition.CellState.EXCLUDED:
					button.text = "X"
					button.modulate = Color.TOMATO
	_accuse_button.disabled = not _session.is_accusation_unlocked()


func _on_undo_pressed() -> void:
	_session.undo_last_move()


func _on_clues_pressed() -> void:
	var text := ""
	for i in range(_session.revealed_clue_count):
		text += "• %s\n" % _session.clue_text(i)
	if text.is_empty():
		text = "No clues revealed yet."
	var label := _clue_dialog.get_label()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	_clue_dialog.popup_centered()


func _on_accuse_pressed() -> void:
	SceneRouter.goto("accusation")


func _on_accusation_unlocked() -> void:
	_accuse_button.disabled = false
	_feedback.text = "The board is complete. Time to make an accusation."


func _on_feedback(message: String) -> void:
	_feedback.text = message
