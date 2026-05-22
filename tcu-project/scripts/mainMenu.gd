class_name MainMenu
extends Control

var template_load_scene_path : String =  "res://scenes/Menus/TemplateLoadingMenu.tscn"
var name_input_scene_path : String = "res://scenes/UI/NamePrompter.tscn"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(name_input_scene_path)

func _on_load_pressed() -> void:
	get_tree().change_scene_to_file(template_load_scene_path)

func _on_exit_pressed() -> void:
	get_tree().quit()
