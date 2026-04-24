class_name ProgramFlow
extends Control

@export var file_reader : FileReader
@export var question_creator : QuestionCreator

var csv_path_example : String = "res://csvImports/QuestionExamples1.csv"
var questions_array : Array = []

func _ready() -> void:
	var text_array = file_reader.loadCSVAsArray(csv_path_example)
	questions_array = file_reader.textToQuestion(text_array)
	question_creator.createQuestionsFromArray(questions_array)
