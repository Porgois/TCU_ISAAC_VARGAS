class_name QuestionTypeSelector
extends Control

@export var option_button : OptionButton = null

signal type_selected(new_type : QUESTION_TYPE)

enum QUESTION_TYPE {
	MATCH,
	COMPLETION,
	MC
}

var current_question_type : QUESTION_TYPE = QUESTION_TYPE.MC

func setCurrentQuestionType(id : int = -1):
	match option_button.get_item_text(id):
		"MULTIPLE CHOICE":
			current_question_type = QUESTION_TYPE.MC
		"COMPLETION":
			current_question_type = QUESTION_TYPE.COMPLETION
		_: # It can only be match
			current_question_type =  QUESTION_TYPE.MATCH

func getCurrentQuestionType() -> QUESTION_TYPE:
	return current_question_type

func setSelectorName(id : int = -1):
	setCurrentQuestionType(id) 
 
#region SIGNALS

func _on_type_selector_item_selected(index: int) -> void:
	setSelectorName(index)
	type_selected.emit(current_question_type)

#endregion
