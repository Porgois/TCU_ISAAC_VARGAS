class_name TeacherResource
extends Resource

@export var positive_responses : Array[String] = []
@export var negative_responses : Array[String] = []

func get_positive_response() -> String:
	return positive_responses.pick_random()

func get_negative_response() -> String:
	return negative_responses.pick_random()
