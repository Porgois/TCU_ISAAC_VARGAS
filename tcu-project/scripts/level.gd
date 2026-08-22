class_name Classroom
extends Node3D

var quiz_ui_scene = preload("res://scenes/ui/QuestionsUI.tscn")

func _ready() -> void:	
	var quiz_ui = quiz_ui_scene.instantiate()
	self.add_child(quiz_ui)
	
	# Setup voice reader to interpret characters
	Global.voice_reader.setupVoiceReader()
