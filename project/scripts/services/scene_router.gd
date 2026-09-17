extends Node
class_name SceneRouter

const SCENES := {
	"bootstrap": "res://scenes/bootstrap.tscn",
	"start_resume": "res://scenes/start_resume.tscn",
	"tutorial": "res://scenes/tutorial.tscn",
	"mansion_explore": "res://scenes/mansion_explore.tscn",
	"case_board": "res://scenes/case_board.tscn",
	"accusation": "res://scenes/accusation.tscn",
	"ending": "res://scenes/ending.tscn",
}

func goto(scene_name: String) -> Error:
	if not SCENES.has(scene_name):
		push_error("Unknown scene: %s" % scene_name)
		return ERR_DOES_NOT_EXIST
	return get_tree().change_scene_to_file(SCENES[scene_name])
