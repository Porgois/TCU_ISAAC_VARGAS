class_name GlobalQuizManager
extends Node

signal quiz_completed(score: int, total: int)

var input_prompt_scene: PackedScene = preload("res://scenes/ui/NamePrompter.tscn")
var question_prompter_scene: PackedScene = preload("res://scenes/ui/generalPrompter.tscn")
var match_environment_scene: PackedScene = preload("res://scenes/ui/matchUI/matchEnvironment.tscn")
var results_screen_scene : PackedScene = preload("res://scenes/ui/resultSummaryScreen/resultsScreen.tscn")

var current_quiz: Quiz = null
var current_teacher : Teacher = null
var current_teacher_dialogue : DialogueResource = null

var questions: Array[Question] = []
var question_handler : QuestionHandler = null

var displayed_name : String = ""
var user_name: String = ""
var quiz_score: int = 0
var total_score: int = 0

var score: int:
	get: return quiz_score
var total: int:
	get: return total_score

var active_balloon = null

func _ready() -> void:
	setDisplayedName("Teacher")

#region TEACHER

func setTeacher(new_teacher: Teacher = null) -> void:
	current_teacher = new_teacher
	print("[QUIZ MANAGER] Teacher \"%s\" saved successfully!" % new_teacher)

func getTeacher() -> Teacher:
	var result : Teacher = null
	
	if current_teacher != null:
		result = current_teacher

	return result

#endregion

#region USER

func setUserName(new_name: String = "") -> void:
	user_name = new_name
	print("[QUIZ MANAGER] User name \"%s\" saved successfully!" % user_name)

func getUserName() -> String:
	return user_name

#endregion

#region DISPLAYEDNAME

func setDisplayedName(new_displayed_name : String = ""):
	displayed_name = new_displayed_name

func getDisplayedName() -> String:
	return displayed_name

#endregion

#region NAME PROMPT

func promptInput() -> void:
	# Show a simple input UI and wait for submission
	var input_scene = input_prompt_scene.instantiate()
	Global.quiz_ui_container.add_child(input_scene)
	
	# Wait for the signal to emit
	await input_scene.input_saved

#endregion

#region QUIZ

func setQuiz(quiz: Quiz) -> void:
	current_quiz = quiz
	print("[QUIZ MANAGER] Quiz \"%s\" loaded successfully!" % quiz.quiz_name)

func getQuiz() -> Quiz:
	return current_quiz

func getQuizName() -> String:
	if current_quiz: # Quiz loadead
		var formatted_name : String = current_quiz.quiz_name.trim_suffix(".csv")
		formatted_name = formatted_name.to_lower().capitalize()
		return formatted_name
	else: # No quiz loaded
		return "ExampleQuiz"

# Starts a quiz, asking all its questions using the separate "presentQuestion" method
func startQuiz(csv_path: String = "") -> void:
	resetScore()

	if current_quiz != null:
		questions = current_quiz.questions
	else:
		var reader := FileReader.new()
		questions = reader.loadCSVQuestions(csv_path)

	total_score = questions.size()

	for question in questions:
		var result := await presentQuestion(question)
		if result.correct:
			quiz_score += 1

	quiz_completed.emit(quiz_score, total_score)

func goToMenu() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/MainMenu.tscn")

func showResultsScreen() -> void:
	# Instantiate result screen scene and fill with summaryItems
	var result_screen : ResultScreen = results_screen_scene.instantiate()
	result_screen.appendItemQuestions(questions)
	
	# Add to tree and await signal
	get_tree().current_scene.add_child(result_screen)
	await result_screen.continueToCompletionImage
	result_screen.queue_free()

func showCompletionImage() -> void:
	var img_generator := ImageGenerator.new()
	get_tree().current_scene.add_child(img_generator)
	await img_generator.createImage("Congratulations ", str(quiz_score))
	img_generator.queue_free()

func loadQuizInFile(quiz_location : String = ""):
	var file_reader : FileReader = FileReader.new()
	file_reader.loadFile(quiz_location, get_tree(), false)
	
#endregion

#region SPECIFIC QUESTION

func getHandler() -> QuestionHandler:
	if question_handler == null:
		question_handler = QuestionHandler.new() # Create handler if it not exists
	
	# Reconfigure each time
	question_handler.configure(displayed_name, active_balloon, Global.quiz_ui_container, question_prompter_scene, match_environment_scene)
	return question_handler

# Asks a single question from the current quiz by index, returns the QuestionResult (or null if the index is invalid).
func askQuestion(question_index: int = 0, trigger_reaction : bool = true) -> QuestionHandler.QuestionResult:
	# Make sure questions are loaded even if startQuiz() hasn't run
	if questions.is_empty() and current_quiz != null:
		questions = current_quiz.questions
		total_score = questions.size()

	if question_index < 0 or question_index >= questions.size():
		printerr("[QUIZ MANAGER] askQuestion: index %d out of range (0-%d)" % [question_index, questions.size() - 1])
		return null

	return await presentQuestion(questions[question_index], trigger_reaction)

# Ask a question of a random index (random question)
func askRandomQuestion() -> QuestionHandler.QuestionResult:
	return await askQuestion(randi() % questions.size())

# Ask any question in the baloon, handling teacher feedback and returns the result
func presentQuestion(question : Question, trigger_reaction : bool = true) -> QuestionHandler.QuestionResult:
	var result : QuestionHandler.QuestionResult = await getHandler().handleQuestion(question)
	
	# Always record the result, even when skipping feedback
	question.was_answered_correctly = result.correct
	
	if not trigger_reaction:
		return result  # Skip feedback dialogue entirely
	
	var feedback_text : String = ""
	if result.correct:
		Global.expression_handler.triggerNeutralReaction()
		feedback_text = displayed_name + ": " + current_teacher.teacher_resource.get_positive_response()
	else:
		Global.expression_handler.triggerNegativeReaction()
		feedback_text = displayed_name + ": " + current_teacher.teacher_resource.get_negative_response()
	
	# Create feedback resourc
	var feedback_resource = DialogueManager.create_resource_from_text("~ feedback\n%s\n=> END" % feedback_text)
	var feedback_line : DialogueLine = await feedback_resource.get_next_dialogue_line("feedback")
	await active_balloon.show_external_text_line(feedback_line, feedback_resource)

	return result

# Gets the correct/wrong value of the question of the given index
func getQuestionResultValue(question_index : float = 0) -> bool:
		if questions.is_empty() and current_quiz != null: # Get questions first
			questions = current_quiz.questions
		
		return questions[question_index].was_answered_correctly

#endregion

#region SCORE

func getScore() -> int:
	return quiz_score

func resetScore() -> void:
	quiz_score = 0

#endregion
