class_name MainMenu
extends Control

var template_load_scene_path : String =  "res://scenes/Menus/TemplateLoadingMenu.tscn"
var start_scene_path : String = "res://scenes/worlds/classroom.tscn"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(start_scene_path)

func _on_load_pressed() -> void:
	get_tree().change_scene_to_file(template_load_scene_path)

func _on_exit_pressed() -> void:
	get_tree().quit()
