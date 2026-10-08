@tool
class_name QuestionAnswer
extends Control

signal question_deleted 

@export var is_deletable : bool = true
@export var delete_button : Button = null

func _ready() -> void:
	if is_deletable:
		delete_button.show()
	else:
		delete_button.hide()

func deleteAnswer():
	## DELETE ANSWER FROM ANSWER LIST
	print("Deleting answer...\n")
	self.queue_free()

#region SIGNALS

func _on_delete_button_pressed() -> void:
	deleteAnswer()
	question_deleted.emit()

#endregion
