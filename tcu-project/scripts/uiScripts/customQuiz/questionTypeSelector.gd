class_name QuestionTypeSelector
extends Control

@export var option_button : OptionButton = null

signal type_selected(new_type : Question.Type)

var current_question_type : Question.Type = Question.Type.MC

# For better human readability
const TYPE_TO_ITEM_TEXT := {
	Question.Type.MC: "MULTIPLE CHOICE",
	Question.Type.COMPLETION: "COMPLETION",
	Question.Type.MATCH: "MATCH"
}

func setCurrentQuestionType(id : int = -1):
	match option_button.get_item_text(id):
		"MULTIPLE CHOICE":
			current_question_type = Question.Type.MC
		"COMPLETION":
			current_question_type = Question.Type.COMPLETION
		_: # It can only be match
			current_question_type =  Question.Type.MATCH

# Set type based on existing question type, dont perform the standard selection actions
func setTypeSilently(type : Question.Type) -> void:
	var wanted : String = TYPE_TO_ITEM_TEXT.get(type, "")
	for i in option_button.item_count:
		if option_button.get_item_text(i).to_upper() == wanted:
			option_button.select(i)  # doesn't emit item_selected
			current_question_type = type
			disableOptionButton()
			return
	printerr("[TYPE SELECTOR] No dropdown item for type: ", Question.Type.keys()[type])

func getCurrentQuestionType() -> Question.Type:
	return current_question_type

func setSelectorName(id : int = -1):
	setCurrentQuestionType(id) 
 
func disableOptionButton():
	# Disable the option button and hide interaction arrow icon
	option_button.disabled = true
	option_button.add_theme_constant_override("arrow_margin", 0)
	option_button.add_theme_icon_override("arrow", ImageTexture.new())

#region SIGNALS

func _on_type_selector_item_selected(index: int) -> void:
	setSelectorName(index)
	type_selected.emit(current_question_type)
	
	# Choose only once
	disableOptionButton()

#endregion
