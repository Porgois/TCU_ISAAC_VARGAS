class_name QuestionAnswer
extends Control

func deleteAnswer():
	## DELETE ANSWER FROM ANSWER LIST
	print("Deleting answer...\n")
	self.queue_free()

#region SIGNALS

func _on_delete_button_pressed() -> void:
	deleteAnswer()

#endregion
