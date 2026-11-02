class_name Classroom
extends Node

@export var teacher_marker : Marker3D = null

func placeTeacher(teacher : Teacher):
	add_child(teacher)
	teacher.global_position = teacher_marker.global_position
	teacher.global_rotation = teacher_marker.global_rotation
