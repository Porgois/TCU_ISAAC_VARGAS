class_name QuizCreationMenu
extends Control

@export var total_question_label : RichTextLabel
@export var total_question_label_preffix : String = "Total questions:"
@export var creator_container : VBoxContainer = null
@export var quiz_name_text : TextEdit = null


var default_custom_quiz_path : String = "res://csvImports/customQuizzes/"
var custom_question_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/customQuestionItem.tscn")
var main_menu_scene_path : String  = "res://scenes/menus/MainMenu.tscn"

var question_count : int = 0
var current_quiz : Quiz = null

func _ready() -> void:
	setup()
	createQuiz() # Create here for now

#region QUIZ-RELATED

func createQuiz():
	current_quiz = Quiz.new()
	setQuizName("EXAMPLE QUIZ")

func setQuizName(text : String = ""):
	if current_quiz != null:
		current_quiz.quiz_name = text

func setQuizQuestions(questions : Array[Question] = []):
	if questions != null:
		current_quiz.questions = questions

func addQuizQuestion(question : Question = null):
	if question != null:
		current_quiz.questions.push_back(question)
		printQuiz()

func saveQuiz():
	var file_reader : FileReader = FileReader.new()
	
	# default_custom_quiz_path is a folder, so add a filename to it
	var file_name : String = current_quiz.quiz_name.validate_filename() + ".csv"
	var full_path : String = default_custom_quiz_path.path_join(file_name)
	
	if file_reader.saveQuizToCSV(current_quiz, full_path):
		print("[QUIZ CREATION MENU] Saved quiz (", current_quiz.quiz_name, ") to: ", full_path, "\n")
	else:
		printerr("[QUIZ CREATION MENU] Failed to save quiz (", current_quiz.quiz_name, ")!\n")
	
	file_reader.free()

func printQuiz():
	current_quiz.printQuiz()

#endregion

#region SETUP

func setupItem(item : CustomQuestionItem) -> void:
	# Connect question deleted signal for existing question item children and set quiz control
	item.question_deleted.connect(deleteQuestionItem)
	item.associated_quiz_creation_menu = self # Set self as quiz control item so that the question item knows \
	# what to set the modal parent to
	item.associated_quiz_creation_menu = self

func setupExistingItems():
	for child in creator_container.get_children():
		if child is CustomQuestionItem:
			setupItem(child)

func setup():
	# Get questions and setup signals
	setupExistingItems()
	refreshQuestions()

func refreshQuestions():
	var number : int = 1 # Start on one to make it more logical for human-reading
	for child in creator_container.get_children():
		if child is CustomQuestionItem and not child.is_queued_for_deletion():
			child.setQuestionNumber(str(number))
			number += 1
	
	question_count = number - 1 # Back to computer-numbering
	updateTotalQuestions() # Update number

#endregion

func addNewQuestionItem():
	var new_question_item : CustomQuestionItem = custom_question_item_scene.instantiate()
	setupItem(new_question_item)
	creator_container.add_child(new_question_item)
	
	refreshQuestions()

func deleteQuestionItem(question_id : int = -1) -> void:
	print("Deleted question with id: ", question_id)
	
	refreshQuestions()

func setupQuestionItemNumber(question_item : CustomQuestionItem = null, number : int = -1):
	question_item.setQuestionNumber(str(number))

#region TOTAL QUESTIONS & QUESTION NUMBER

# Calculate question numbers
func recalculateQuestionNumbers():
	var current_question_count : int = 0
	
	for child in creator_container.get_children():
		if child is CustomQuestionItem:
			child.setQuestionNumber(str(current_question_count))
			current_question_count += 1

# Change total question label based on the question container's children
func updateTotalQuestions() -> void:
	total_question_label.text = total_question_label_preffix + " " + str(question_count)

func getInitialQuestionCount():
	question_count = creator_container.get_child_count()
	updateTotalQuestions()

#endregion

#region SIGNALS

func _on_new_button_pressed() -> void:
	addNewQuestionItem()

func _on_save_button_pressed() -> void:
	saveQuiz()

func _on_quiz_title_text_changed() -> void:
	setQuizName(quiz_name_text.text)

# Go back to menu for now
func _on_cancel_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene_path)

#endregion
