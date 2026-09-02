class_name GlobalQuizManager
extends Node

signal quiz_completed(score: int, total: int)

var input_prompt_scene: PackedScene = preload("res://scenes/ui/NamePrompter.tscn")
var question_prompter_scene: PackedScene = preload("res://scenes/ui/genericPrompter.tscn")
var match_environment_scene: PackedScene = preload("res://scenes/ui/matchUI/matchEnvironment.tscn")
var current_quiz: Quiz = null
var current_teacher : Teacher = null

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
	var formatted_name : String = current_quiz.quiz_name.trim_suffix(".csv")
	formatted_name = formatted_name.to_lower().capitalize()
	return formatted_name

func startQuiz(csv_path: String = "") -> void:
	resetScore()

	var questions: Array[Question] = []
	if current_quiz != null:
		questions = current_quiz.questions
	else:
		var reader := FileReader.new()
		questions = reader.loadQuestionsFromCSV(csv_path)

	total_score = questions.size()

	var handler := QuestionHandler.new()
	handler.configure(displayed_name, active_balloon, Global.quiz_ui_container, question_prompter_scene, match_environment_scene)

	for question in questions:
		var result: QuestionHandler.QuestionResult = await handler.handleQuestion(question)

		if result.correct:
			quiz_score += 1

		# Build and show the feedback line based on correct/incorrect
		var feedback_text: String
		if result.correct:
			feedback_text = displayed_name + ": " + current_teacher.teacher_resource.get_positive_response()
		else:
			feedback_text = displayed_name + ": " + current_teacher.teacher_resource.get_negative_response()

		var feedback_resource = DialogueManager.create_resource_from_text(
			"~ feedback\n%s\n=> END" % feedback_text
		)
		var feedback_line = await feedback_resource.get_next_dialogue_line("feedback")
		await active_balloon.show_external_text_line(feedback_line, feedback_resource)

	# All questions done, signal the outer '.dialogue' to resume
	quiz_completed.emit(quiz_score, total_score)

func goToMenu() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/MainMenu.tscn")

func showCompletionImage() -> void:
	var img_generator := ImageGenerator.new()
	get_tree().current_scene.add_child(img_generator)
	await img_generator.createImage("Congratulations ", str(quiz_score))
	img_generator.queue_free()

#endregion

#region SCORE

func getScore() -> int:
	return quiz_score

func resetScore() -> void:
	quiz_score = 0

#endregion
