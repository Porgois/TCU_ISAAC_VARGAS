class_name QuestionAnswer
extends Control

signal question_deleted 

@export var is_deletable : bool = true
@export var is_markable_as_correct : bool = false
@export var delete_button : Button = null
@export var question_input : QuestionInputField = null
@export var correct_check : CheckBox = null  # Multiple choice only, hidden by default in the scene

func _ready() -> void:
	# Check for deletion
	if is_deletable:
		showDeleteButton()
	else:
		hideDeleteButton()
		
	# Check for correct-markable
	if is_markable_as_correct:
		showCorrectButton()
	else:
		hideCorrectButton()

#region DATA

# Gets the text input from its question input field child
func getInputText() -> String:
	var result : String = ""
	
	if question_input:
		result = question_input.getInputText()
	
	return result

# Sets the text of its question input field child
func setInputText(new_text : String = "") -> void:
	if question_input:
		question_input.setInputText(new_text)

#endregion

#region CORRECT ANSWER (MULTIPLE CHOICE)

func setCorrectGroup(group : ButtonGroup) -> void:
	if correct_check:
		correct_check.button_group = group

func setCorrectCheckVisible(value : bool) -> void:
	if correct_check:
		if value:
			showCorrectButton()
		else:
			hideCorrectButton()

func showCorrectButton():
	correct_check.modulate.a = 1.0
	correct_check.mouse_filter = Control.MOUSE_FILTER_STOP # Can be interacted with
	correct_check.focus_mode = Control.FOCUS_ALL

func hideCorrectButton():
	correct_check.modulate.a = 0.0
	correct_check.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Can't be interacted with
	correct_check.focus_mode = Control.FOCUS_NONE

func setCorrect(value : bool) -> void:
	if correct_check:
		correct_check.button_pressed = value

func isCorrect() -> bool:
	return correct_check != null and correct_check.button_pressed

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
