class_name LevelRandomizer
extends Node

#region SCENES

@export var teacher_scenes : Array[PackedScene] = []
@export var classroom_scenes : Array[PackedScene] = []

#endregion

# Gets a random scene from the any of scene lists, returns object
func getRandomTeacher() -> Teacher:
	return teacher_scenes.pick_random().instantiate()

func getRandomClassroom() -> Classroom:
	return classroom_scenes.pick_random().instantiate()
	
func getRandomDialogue(teacher : Teacher = null) -> DialogueResource:
	var dialogue : DialogueResource = null

	if teacher != null:
		dialogue = teacher.getDialogueArray().pick_random()
	
	return dialogue
