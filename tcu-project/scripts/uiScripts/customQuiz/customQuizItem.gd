class_name CustomQuizItem
extends Control

@export var quiz_name : RichTextLabel = null

var quiz_creation_scene_path : String = "res://scenes/ui/customQuestion/customQuizCreator.tscn"

func setQuizNameText(new_text : String = ""):
	if quiz_name:
		quiz_name.text = new_text

func setCreatorEnvironment():
	pass

func goToQuizCreator():
	get_tree().change_scene_to_file(quiz_creation_scene_path)

#region SIGNALS

func _on_edit_button_pressed() -> void:
	setCreatorEnvironment()
	goToQuizCreator()

#endregion
