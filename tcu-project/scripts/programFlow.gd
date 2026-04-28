class_name ProgramFlow
extends Control

@export var question_label : RichTextLabel
@export var options_container : HSplitContainer

var button_scene = preload("res://scenes/UI/QuestionButton.tscn")

var questions: Array[Question] = []
var current_index: int = 0
var score : int = 0

func _ready() -> void:
	loadQuiz("res://csvImports/QuestionExamples1.csv")

func loadQuiz(csv_path: String):
	var reader = FileReader.new()
	var raw = reader.loadCSVAsArray(csv_path)
	questions = reader.textToQuestions(raw)
	showQuestion(current_index)

func showQuestion(index: int):
	if index >= questions.size():
		question_label.text = "Quiz completed!\nYour score is: " + str(score) + ".\n"
		return

	var q: Question = questions[index]

	# Set your question label
	question_label.text = q.question_prompt

	# Populate option buttons dynamically
	for option in q.options:
		var button = button_scene.instantiate()
		button.text = option.text
		# Pass is_correct into the callback to determine if question is correct or not
		button.pressed.connect(func(): onOptionSelected(option.is_correct))
		options_container.add_child(button)

func onOptionSelected(is_correct: bool):
	if is_correct:
		print("Correct!")
		score += 1
	else:
		print("Wrong!")

	# Clear buttons before showing next question
	for child in options_container.get_children():
		child.queue_free()

	current_index += 1
	showQuestion(current_index)
