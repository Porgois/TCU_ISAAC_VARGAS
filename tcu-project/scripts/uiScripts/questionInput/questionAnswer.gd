class_name QuestionAnswer
extends Control

signal question_deleted 

@export var is_deletable : bool = true
@export var delete_button : Button = null
@export var question_input : QuestionInputField = null

func _ready() -> void:
	if is_deletable:
		showDeleteButton()
	else:
		hideDeleteButton()

#region DATA

# Gets the text input from its question input field child
func getInputText() -> String:
	var result : String = ""
	
	if question_input:
		result = question_input.getInputText()
	
	return result

#endregion

#region DELETION

func showDeleteButton():
	delete_button.modulate.a = 1.0
	delete_button.mouse_filter = Control.MOUSE_FILTER_STOP # Can be interacted with
	delete_button.focus_mode = Control.FOCUS_ALL

func hideDeleteButton():
	delete_button.modulate.a = 0.0
	delete_button.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Can't be interacted with
	delete_button.focus_mode = Control.FOCUS_NONE

func deleteAnswer():
	## DELETE ANSWER FROM ANSWER LIST
	print("Deleting answer...\n")
	self.queue_free()

#endregion

#region SIGNALS

func _on_delete_button_pressed() -> void:
	deleteAnswer()
	question_deleted.emit()

#endregion
