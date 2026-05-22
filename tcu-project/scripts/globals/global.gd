class_name Global
extends Node

var user_name : String = ""
var current_quiz : Quiz = null

func setUserName(new_name : String = ""):
	self.user_name = new_name
	print("[QUIZ MANAGER] User name \"" + self.user_name + "\" saved succesfully!\n")

func getUserName():
	if user_name != "" or user_name != null:
		return self.user_name

func setQuiz(quiz : Quiz):
	self.current_quiz = quiz
	print("[QUIZ MANAGER] Quiz \"" + quiz.name + "\" loaded succesfully!\n")

func getQuiz() -> Quiz:
	if current_quiz != null:
		return current_quiz
	else:
		return null
