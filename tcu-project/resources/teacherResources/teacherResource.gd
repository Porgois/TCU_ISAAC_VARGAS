class_name TeacherResource
extends Resource

@export var teacher_name : String = ""
@export var teacher_surname : String = ""
@export_enum("Male", "Female") var teacher_gender: String = "Male"

@export_range(0.4, 2.5, 0.1) var voice_pitch : float = 1.4
@export var teacher_dialogue : DialogueResource
@export var positive_responses : Array[String] = []
@export var negative_responses : Array[String] = []

func get_positive_response() -> String:
	return positive_responses.pick_random()

func get_negative_response() -> String:
	return negative_responses.pick_random()
