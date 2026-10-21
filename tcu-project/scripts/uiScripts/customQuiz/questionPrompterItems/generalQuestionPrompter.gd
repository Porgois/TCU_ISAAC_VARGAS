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
	question_answer_texts.push_back(answer.getInputText())

func setAnswers():
	question_answer_texts.clear() # Clear first
	
	for answer in question_answers_container.get_children():
		setAnswerText(answer) # Gets text from the answer field and stores it inside the array

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
		for answer in question_answer_texts:
			question_item.addQuestionAnswer(answer)

# Sets the local question prompt as the associated question item's question text (prompt)
func setQuestionPrompt():
	var question_item = associated_creation_modal.getQuestionItem()
	
	if question_item != null:
		question_item.setQuestionText(question_text)

# Compiles all other methods to save all the question data
func saveQuestion():
	setQuestionPrompt()
	setQuestionAnswers()
	
	print("[QUESTION PROMPTER] Saved question data!\n")

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
