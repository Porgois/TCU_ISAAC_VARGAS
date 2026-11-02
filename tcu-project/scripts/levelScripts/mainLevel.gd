class_name MainLevel
extends Node3D

var quiz_ui_scene = preload("res://scenes/ui/QuestionsUI.tscn")
@export var parent_node : Node3D = null
@export var game_randomizer : LevelRandomizer = null

func _ready() -> void:
	# Random teacher & classroom
	setup()
	
	# Quiz interface
	var quiz_ui = quiz_ui_scene.instantiate()
	self.add_child(quiz_ui)
	
	# Setup voice reader to interpret characters
	Global.voice_reader.setupVoiceReader()

# Spawns random teacher inside a random classroom
func setup():
	var teacher : Teacher = game_randomizer.getRandomTeacher()
	print("Teacher name: ", teacher.name)
	var classroom : Classroom = game_randomizer.getRandomClassroom()
	parent_node.add_child(classroom)
	
	classroom.placeTeacher(teacher)
