class_name QuestionTypeSelector
extends Control

@export var selector : MenuBar = null
@export var popup_menu : PopupMenu = null

signal type_selected(new_type : QUESTION_TYPE)

enum QUESTION_TYPE {
	MATCH,
	COMPLETION,
	MULTIPLE_CHOICE
}

var current_question_type : QUESTION_TYPE = QUESTION_TYPE.MULTIPLE_CHOICE

func setCurrentQuestionType(id : int = -1):
	match popup_menu.get_item_text(id):
		"MULTIPLE CHOICE":
			current_question_type = QUESTION_TYPE.MULTIPLE_CHOICE
		"COMPLETION":
			current_question_type = QUESTION_TYPE.COMPLETION
		_: # It can only be match
			current_question_type =  QUESTION_TYPE.MATCH
		
	print("Current question set to: ", QUESTION_TYPE.keys()[current_question_type])
	
func getCurrentQuestionType() -> QUESTION_TYPE:
	return current_question_type

func setSelectorName(id : int = -1):
	setCurrentQuestionType(id)
	selector.set_menu_title(0, popup_menu.get_item_text(id)) 
 
#region SIGNALS

func _on_question_type_id_pressed(id : int = -1) -> void:
	setSelectorName(id)
	type_selected.emit(current_question_type)

#endregion
