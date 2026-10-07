class_name MainMenu
extends Control

var start_scene_path : String = "res://scenes/worlds/classroom.tscn"
var template_load_scene_path : String =  "res://scenes/Menus/TemplateLoadingMenu.tscn"
var create_scene_path : String = "res://scenes/menus/quizCreationMenu.tscn"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(start_scene_path)

func _on_load_pressed() -> void:
	get_tree().change_scene_to_file(template_load_scene_path)

func _on_create_pressed() -> void:
	get_tree().change_scene_to_file(create_scene_path)

func _on_exit_pressed() -> void:
	get_tree().quit()
