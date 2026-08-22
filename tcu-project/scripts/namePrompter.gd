class_name NamePrompter
extends Control

@export var input_menu : Control = null
@export var input_field : LineEdit = null

var quiz_scene_path : String = "res://scenes/worlds/classroom.tscn"
var input_field_contents : String = ""
var transition_duration : float = 0.1

signal input_saved

func _ready() -> void:
	input_field.text_changed.connect(onTextEntered)
	
func onTextEntered(new_text : String = ""):
	input_field_contents = new_text
	print("Contents: ", input_field_contents)

func _on_button_pressed() -> void:
	QuizManager.setUserName(input_field_contents)
	input_menu.hide()

	await get_tree().create_timer(transition_duration).timeout
	input_saved.emit()
	self.queue_free()
