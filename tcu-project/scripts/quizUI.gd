class_name QuizUI
extends Control

@export var quiz_canvas_layer : CanvasLayer

func _ready() -> void:
	Global.setQuizUiContainer(quiz_canvas_layer)
	
	var dialogue = load("res://dialogues/example.dialogue")
	var balloon = DialogueManager.show_dialogue_balloon(dialogue, "start")
	QuizManager.active_balloon = balloon
