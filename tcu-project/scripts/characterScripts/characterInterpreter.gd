class_name CharacterInterpreter
extends Node

# Characters to be ignored by mouth movement
const SILENT_CHARACTERS := [".", ",", "!", "?", "_", "\n", "\"", "'", " "]

@export var voice_reader : VoiceReader = null
var expression_handler : ExpressionHandler = null

func _ready() -> void:
	self.process_priority = 1 # Assign itself before dialogue box
	Global.setCharacterInterpreter(self)
	
	# Set expression handler
	expression_handler = Global.expression_handler

func processCharacter(character: String, _speed: float, _extra: bool):
	# Voice
	voice_reader.playCharacter(character)
	
	# Only move mouth if an actual letter or number is being read
	if character.strip_edges() != "" and not character in SILENT_CHARACTERS:
		# Mouth
		expression_handler.play_speak_animation()
