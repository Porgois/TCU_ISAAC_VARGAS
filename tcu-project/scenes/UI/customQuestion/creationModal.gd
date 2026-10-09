class_name QuestionCreationModal
extends Control

var associated_question_item : CustomQuestionItem = null

#region MODAL

func closeModal():
	if self.visible: # Only hide for now
		self.hide()

func deleteModal():
	self.queue_free()

#endregion

func saveQuestion():
	pass

func cancel():
	closeModal()

#region SIGNALS

func _on_cancel_button_pressed() -> void:
	cancel()

#endregion
