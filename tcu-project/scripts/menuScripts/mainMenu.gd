class_name MainMenu
extends Control

var start_scene_path : String = "res://scenes/worlds/classroom.tscn"
var template_load_scene_path : String =  "res://scenes/Menus/TemplateLoadingMenu.tscn"
var create_scene_path : String = "res://scenes/menus/customQuizzesMenu.tscn"

var tutorial_dialogue : DialogueResource = preload("res://dialogues/tutorialDialogue.dialogue")

#region FUNCTIONALITY

func setupTutorial():
	print("SETUP TUTORIAL")
	QuizManager.current_teacher_dialogue = tutorial_dialogue # Set dialogue to the explicatory tutorial one

#endregion

#region SIGNALS

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(start_scene_path)

func _on_load_pressed() -> void:
	get_tree().change_scene_to_file(template_load_scene_path)

func _on_create_pressed() -> void:
	get_tree().change_scene_to_file(create_scene_path)

func _on_tutorial_pressed() -> void:
	setupTutorial() # Change dialogue before entering the scene
	get_tree().change_scene_to_file(start_scene_path)

func _on_exit_pressed() -> void:
	get_tree().quit()

#endregion
