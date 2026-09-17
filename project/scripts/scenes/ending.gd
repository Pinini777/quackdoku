extends Control
class_name Ending

@onready var _session: CaseSession = get_node("/root/CaseSession")


func _ready() -> void:
	anchors_preset = PRESET_FULL_RECT
	_build_ui()


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(PRESET_FULL_RECT, PRESET_MODE_MINSIZE, 20)
	root.add_theme_constant_override("separation", 20)
	add_child(root)

	var data := _session.ending_data()

	var closed := Label.new()
	closed.text = "Case Closed"
	closed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	closed.add_theme_font_size_override("font_size", 40)
	root.add_child(closed)

	var revelation := Label.new()
	revelation.text = data.get("revelation", "The truth is revealed.")
	revelation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	revelation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	revelation.add_theme_font_size_override("font_size", 22)
	root.add_child(revelation)

	var collectible := data.get("collectible", {}) as Dictionary
	if not collectible.is_empty():
		var box := PanelContainer.new()
		root.add_child(box)

		var inner := VBoxContainer.new()
		inner.add_theme_constant_override("separation", 8)
		box.add_child(inner)

		var award := Label.new()
		award.text = "Awarded: %s" % collectible.get("name", "")
		award.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		award.add_theme_font_size_override("font_size", 26)
		inner.add_child(award)

		var desc := Label.new()
		desc.text = collectible.get("description", "")
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size", 18)
		inner.add_child(desc)

	var hook := Label.new()
	hook.text = data.get("hook", "")
	hook.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hook.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hook.add_theme_font_size_override("font_size", 20)
	root.add_child(hook)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	root.add_child(actions)

	var again := Button.new()
	again.text = "Play Again"
	again.custom_minimum_size = Vector2(180, 72)
	again.pressed.connect(_on_play_again)
	actions.add_child(again)

	var menu := Button.new()
	menu.text = "Main Menu"
	menu.custom_minimum_size = Vector2(180, 72)
	menu.pressed.connect(_on_main_menu)
	actions.add_child(menu)


func _on_play_again() -> void:
	_session.discard_progress()
	_session.start_case()
	SceneRouter.goto("case_board")


func _on_main_menu() -> void:
	_session.discard_progress()
	SceneRouter.goto("start_resume")
