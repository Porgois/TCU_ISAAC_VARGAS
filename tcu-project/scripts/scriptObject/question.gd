class_name Question
extends Node

# Stores the actual question prompt
var question_prompt : String = ""
# Stores the options related to the question
var options : Array[QuestionOption] = []

func setQuestionPrompt(text : String = ""):
	self.question_prompt = text

func addQuestionOption(option : QuestionOption):
	self.options.append(option)
