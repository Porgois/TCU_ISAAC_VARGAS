class_name Teacher
extends Node

@export var teacher_resource : TeacherResource

func _ready() -> void:
	QuizManager.setTeacher(self)
