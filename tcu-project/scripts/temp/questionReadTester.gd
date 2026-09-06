extends Node

var csv_example_path : String = "res://csvImports/EXAMPLE.csv"
var questions : Array[Question] = []
var file_reader : FileReader = null

func _ready() -> void:
	file_reader = FileReader.new()
	questions = file_reader.loadCSVQuestions(csv_example_path)
	file_reader.printQuestions(questions)
