class_name Teacher
extends Node

@export var teacher_resource : TeacherResource

func getName() -> String:
	return teacher_resource.teacher_name

func getSurname() -> String:
	return teacher_resource.teacher_surname

func getFullName() -> String:
	return getName() + " " + getSurname()

func getHonorific() -> String:
	var honorific : String = "Mr."
	
	if teacher_resource.teacher_gender == "Female":
		honorific = "Ms."
	
	return honorific

func getFormalName() -> String:
	return getHonorific() + " " + getSurname()

func _ready() -> void:
	QuizManager.setTeacher(self)
