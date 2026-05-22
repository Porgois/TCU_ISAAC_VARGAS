class_name QuizHandler
extends Control

@export var question_label : RichTextLabel
@export var options_container : HSplitContainer

var button_scene = preload("res://scenes/UI/QuestionButton.tscn")

var current_quiz : Quiz = null
var current_index: int = 0
var score : int = 0

## MOVE THIS SOMEWHERE ELSE
func _ready() -> void:
	if QuizManager.getQuiz() == null:
		current_quiz = loadQuiz("res://csvImports/QuestionExamples1.csv")
	else:
		current_quiz = QuizManager.getQuiz()
	
	showQuestion(current_index)

func loadQuiz(csv_path: String) -> Quiz:
	# Create support classes
	var reader = FileReader.new()
	var raw = reader.loadCSVAsArray(csv_path)
	
	# Create and return quiz
	var quiz = Quiz.new()
	quiz.name = csv_path.get_file()
	quiz.questions = reader.textToQuestions(raw)

	return quiz

func showQuestion(index: int):
	# Quest done
	if index >= current_quiz.questions.size():
		question_label.text = "Quiz completed!\nYour score is: " + str(score) + ".\n"
		
		# Create image with score
		var img_generator : ImageGenerator = ImageGenerator.new()
		add_child(img_generator)
		
		await img_generator.create_image("Congratulations ", str(score))
		img_generator.queue_free()
		
		return

	var q: Question = current_quiz.questions[index]

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
