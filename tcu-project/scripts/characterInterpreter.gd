class_name CharacterInterpreter
extends Node

@export var voice_reader : VoiceReader

func _ready() -> void:
	self.process_priority = 1 # Assign itself before dialogue box
	Global.setCharacterInterpreter(self)

func processCharacter(character: String, _speed: float, _extra: bool):
	print("[CHARACTER INTERPRETER] character: ", character, ".\n")
	voice_reader.playCharacter(character)
