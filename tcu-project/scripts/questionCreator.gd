class_name QuestionCreator
extends Node

@export var questions_container : HSplitContainer
var question_scene = preload("res://scenes/UI/QuestionButton.tscn")

func createQuestionsFromArray(questions_array : Array[Question]):
	for element in questions_array:
		var question_button : QuestionButton = question_scene.instantiate()
		
		# Set question and values
		question_button.question = element
		question_button.set_question_values(element.text, element.is_correct)
		
		# Add question
		questions_container.add_child(question_button)
