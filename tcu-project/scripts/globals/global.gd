extends Node

var quiz_ui_container : CanvasLayer
var character_interpreter : CharacterInterpreter

func setQuizUiContainer(quiz_ui : CanvasLayer = null):
	self.quiz_ui_container = quiz_ui

func setCharacterInterpreter(interpreter : CharacterInterpreter = null):
	self.character_interpreter = interpreter
