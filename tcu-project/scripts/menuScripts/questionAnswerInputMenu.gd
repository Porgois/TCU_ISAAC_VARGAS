extends Control

@export var question_answer_container : VBoxContainer = null

var text_input_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionAnswerInput.tscn")

func addAnswerInputItem():
	var answer_input_field : QuestionAnswer = text_input_scene.instantiate()
	
	# Add to container
	if question_answer_container != null:
		question_answer_container.add_child(answer_input_field)

#region SIGNALS

func _on_button_pressed() -> void:
	addAnswerInputItem()

#endregion
