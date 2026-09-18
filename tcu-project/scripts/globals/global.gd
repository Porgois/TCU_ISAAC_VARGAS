extends Node

var quiz_ui_container : CanvasLayer
var character_interpreter : CharacterInterpreter
var voice_reader : VoiceReader
var expression_handler : ExpressionHandler

func setQuizUiContainer(quiz_ui : CanvasLayer = null):
	self.quiz_ui_container = quiz_ui

func setCharacterInterpreter(interpreter : CharacterInterpreter = null):
	self.character_interpreter = interpreter

func setVoiceReader(reader : VoiceReader = null):
	self.voice_reader = reader

func setExpressionHandler(e_handler : ExpressionHandler = null):
	self.expression_handler = e_handler
