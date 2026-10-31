class_name QuizCreationMenu
extends Control

@export var total_question_label : RichTextLabel
@export var total_question_label_preffix : String = "Total questions:"
@export var creator_container : VBoxContainer = null
@export var quiz_name_text : LineEdit = null

var default_custom_quiz_path : String = QuizSession.CUSTOM_QUIZ_PATH
var custom_question_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/customQuestionItem.tscn")
var custom_quizzes_menu_scene_path : String  = "res://scenes/menus/customQuizzesMenu.tscn"

var question_count : int = 0
var current_quiz : Quiz = null

func _ready() -> void:
	setup()
	
	if QuizSession.pending_csv_path != "":
		loadQuizFromCSV(QuizSession.pending_csv_path)
		QuizSession.pending_csv_path = ""  # consume it, so "new quiz" starts empty next time
	else:
		createQuiz()

#region QUIZ-RELATED

func createQuiz():
	current_quiz = Quiz.new()
	setQuizName("UntitledQuiz")

func setQuizName(text : String = ""):
	if current_quiz != null:
		current_quiz.quiz_name = text

func setQuizQuestions(questions : Array[Question] = []):
	if questions != null:
		current_quiz.questions = questions

func collectQuestionsFromItems() -> Array[Question]:
	var questions : Array[Question] = []
	for child in creator_container.get_children():
		if child is CustomQuestionItem and not child.is_queued_for_deletion():
			var q : Question = child.associated_question
			if q != null and q.question.strip_edges() != "":  # skip never-edited items
				questions.append(q)
	return questions

func saveQuiz():
	var file_reader : FileReader = FileReader.new()
	
	# Rebuild from the items so edits overwrite, deletes are respected, and order matches the UI
	setQuizQuestions(collectQuestionsFromItems())
	
	var file_name : String = current_quiz.quiz_name.validate_filename() + ".csv"
	var full_path : String = default_custom_quiz_path.path_join(file_name)
	
	if file_reader.saveQuizToCSV(current_quiz, full_path):
		print("[QUIZ CREATION MENU] Saved quiz (", current_quiz.quiz_name, ") to: ", full_path, "\n")
	else:
		printerr("[QUIZ CREATION MENU] Failed to save quiz (", current_quiz.quiz_name, ")!\n")
	
	file_reader.free()
	
	# Notify of quiz alteration/creation and return to quiz menu
	MessageNotifier.showMessage(get_tree(), "Quiz saved succesfully!\n", 2.0, custom_quizzes_menu_scene_path)

func loadQuizFromCSV(csv_path : String) -> void:
	var file_reader : FileReader = FileReader.new()
	var quiz : Quiz = Quiz.new()
	quiz.quiz_name = csv_path.get_file().get_basename()
	quiz.questions = file_reader.loadCSVQuestions(csv_path)
	file_reader.free()
	
	loadQuiz(quiz)

func loadQuiz(quiz : Quiz) -> void:
	current_quiz = quiz
	quiz_name_text.text = quiz.quiz_name  # No text_changed signal from code

	for child in creator_container.get_children():
		if child is CustomQuestionItem:
			creator_container.remove_child(child)
			child.queue_free()

	for question in quiz.questions:
		var item : CustomQuestionItem = custom_question_item_scene.instantiate()
		item.associated_question = question # Before add_child so _ready() keeps it
		setupItem(item)
		creator_container.add_child(item)
		item.loadFromQuestion(question) # After add_child so exports are resolved

	refreshQuestions()

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
	if await ConfirmationModal.ask("Save changes?", "This will create a new quiz file in your hardrive."):
		saveQuiz()

func _on_quiz_title_text_changed(new_text : String) -> void:
	setQuizName(new_text)

# Go back to menu for now
func _on_cancel_button_pressed() -> void:
	if await ConfirmationModal.ask("Cancel changes?", "Any changes made will be undone."):
		get_tree().change_scene_to_file(custom_quizzes_menu_scene_path)

#endregion
