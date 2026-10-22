class_name GeneralQuestionPrompter
extends Control

@export var question_input : QuestionInputField = null
@export var question_answers_container : VBoxContainer = null

var question_text : String = ""
var question_answer_texts : Array[String] = []
var associated_creation_modal : QuestionCreationModal = null # Get to associated question item through the modal

#region TEXT EXTRACTION

## Getters

func getQuestionText() -> String:
	return question_text

func getAnswerTexts() -> Array[String]:
	return question_answer_texts

## Setters

# Sets the question preview text
func setQuestionPreviewText():
	if associated_creation_modal != null:
		associated_creation_modal.associated_question_item.setQuestionPreview(question_text) # Set preview text

# Basic question prompt text
func setQuestionText():
	question_text = question_input.getInputText()

# Question answers
func setAnswerText(answer : QuestionAnswer = null):
	var text : String = answer.getInputText().strip_edges()
	if text != "":
		question_answer_texts.push_back(text)

# Set answers for a given question
func setAnswers():
	question_answer_texts.clear()
	for answer in question_answers_container.get_children():
		if answer.is_queued_for_deletion():
			continue
		setAnswerText(answer)

# Stores question and prints text, if need be
func submitQuestion(print_text : bool = false):
	setQuestionText()
	setAnswers()
	
	# Save associated question data
	saveQuestion()

	if print_text:
		printPrompt()
		printAnswers()

#endregion

#region QUESTION SAVING

# Sets associated question item's question answers to the local answer array
func setQuestionAnswers():
	var question_item = associated_creation_modal.getQuestionItem()
	if question_item != null:
		question_item.associated_question.answers.assign(question_answer_texts)  # overwrite

# Sets the local question prompt as the associated question item's question text (prompt)
func setQuestionPrompt():
	var question_item = associated_creation_modal.getQuestionItem()
	
	if question_item != null:
		question_item.setQuestionText(question_text)

# Compiles all other methods to save all the question data
func saveQuestion():
	setQuestionPrompt()
	setQuestionAnswers()
	
	print("[COMPLETION QUESTION PROMPTER] Saved question data!\n")

#endregion

#region LOAD FROM EXISTING QUIZ

func loadFromQuestion(question : Question) -> void:
	question_input.setInputText(question.question)
	fillAnswerRows(question.answers)

func getAnswerMenu() -> QuestionAnswerMenu:
	var node : Node = question_answers_container
	while node != null and not node is QuestionAnswerMenu:
		node = node.get_parent()
	return node as QuestionAnswerMenu

func fillAnswerRows(texts : Array[String]) -> void:
	var menu : QuestionAnswerMenu = getAnswerMenu()
	if menu != null:
		menu.ensureAnswerCount(texts.size())
	
	var rows : Array[Node] = question_answers_container.get_children()
	for i in rows.size():
		var row : QuestionAnswer = rows[i] as QuestionAnswer
		if row != null:
			row.setInputText(texts[i] if i < texts.size() else "")

#endregion

#region MISC

func printPrompt():
	print("Question prompt:\n", question_text)

func printAnswers():
	print("Question answers:")
	var count = 0
	for answer in question_answer_texts:
		print("Answer #", count, ": ", answer)
		count += 1

#endregion
