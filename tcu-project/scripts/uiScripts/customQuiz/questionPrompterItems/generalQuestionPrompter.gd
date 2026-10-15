class_name GeneralQuestionPrompter
extends Control

@export var question_input : QuestionInputField = null
@export var question_answers_container : VBoxContainer = null

var question_text : String = ""
var question_answer_texts : Array[String] = []
var associated_creation_modal : QuestionCreationModal = null

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
	for answer in question_answers_container.get_children():
		setAnswerText(answer) # Gets text from the answer field and stores it inside the array

# Stores question and prints text, if need be
func submitQuestion(print_text : bool = false):
	setQuestionText()
	setAnswers()
	
	if print_text:
		printPrompt()
		printAnswers()

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
