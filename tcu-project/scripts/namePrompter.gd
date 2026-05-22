class_name NamePrompter
extends Control

@export var input_menu : Control = null
@export var confirmation : Control = null
@export var input_field : LineEdit = null

var quiz_scene_path : String = "res://scenes/UI/QuestionsUI.tscn"
var input_field_contents : String = ""
var transition_duration : float = 1.0

func _ready() -> void:
	input_field.text_changed.connect(onTextEntered)
	
func onTextEntered(new_text : String = ""):
	input_field_contents = new_text
	print("Contents: ", input_field_contents)

func _on_save_pressed() -> void:
	QuizManager.setUserName(input_field_contents)
	input_menu.hide()
	confirmation.show()
	
	await get_tree().create_timer(transition_duration).timeout
	get_tree().change_scene_to_file(quiz_scene_path)
