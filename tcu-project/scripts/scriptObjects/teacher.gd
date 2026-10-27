class_name Teacher
extends Node

@export var teacher_resource : TeacherResource

func _ready() -> void:
	QuizManager.setTeacher(self)

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

#region DIALOGUE

func setDialogue(new_dialogue : DialogueResource = null):
	if teacher_resource.teacher_dialogue:
		print("SET NEW DIALOGUE TO: ", new_dialogue)
		teacher_resource.teacher_dialogue = new_dialogue

func getDialogue() -> DialogueResource:
	var result : DialogueResource = null
	
	if teacher_resource.teacher_dialogue != null:
		result = teacher_resource.teacher_dialogue
	
	return result

#endregion
