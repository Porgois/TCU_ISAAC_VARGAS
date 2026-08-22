class_name QuizUI
extends Control

@export var quiz_canvas_layer : CanvasLayer

func _ready() -> void:
	print("QUIZ UI\n")
	Global.setQuizUiContainer(quiz_canvas_layer)
	
	var dialogue = QuizManager.current_teacher.teacher_resource.teacher_dialogue
	var balloon = DialogueManager.show_dialogue_balloon(dialogue, "start")
	QuizManager.active_balloon = balloon
