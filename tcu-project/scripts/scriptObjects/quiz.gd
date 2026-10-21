class_name Quiz
extends Node

var quiz_name : String = ""
var questions : Array[Question] = []

func printQuiz():
	print("------", quiz_name, "------")
	printQuizQuestions()

func printQuizQuestions():
	var counter : int = 0
	
	for question in questions:
		print("---Question #", counter, ": ", question.question, "---") # Print prompt
		print("---Answers---")
		for answer in question.answers:
			print(answer)
		counter+= 1
