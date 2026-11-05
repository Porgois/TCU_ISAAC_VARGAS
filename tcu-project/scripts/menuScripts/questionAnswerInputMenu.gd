class_name QuestionAnswerMenu
extends VBoxContainer

@export var question_answer_container : VBoxContainer = null
@export var max_answer_count : int = 8 # Max number of answers that can be added
@export var placeholder_text : String = "Enter answer content here..."
@export var external_add_button : GeneralButton = null

var text_input_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionAnswerInput.tscn")
var current_answer_count : int = 0

# First answer already created
func _ready() -> void:
	addAnswerInputItem(false) # Not deletable (at least one answer)
	external_add_button.pressed.connect(addAnswerInputItem)

#region COUNT

func addAnswerInputItem(is_deletable : bool = true) -> void:
	if question_answer_container == null:
		return
	
	if getAnswerFields().size() >= max_answer_count:
		print("[QUESTION ANSWER MENU] Warning: Can't add more answers!\n")
		return
	
	# Create and set values
	var answer_input_field : QuestionAnswer = text_input_scene.instantiate()
	answer_input_field.is_deletable = is_deletable
	answer_input_field.setPlaceholderText(placeholder_text)
	
	# Add to container, then number everything from the real order
	question_answer_container.add_child(answer_input_field)
	answer_input_field.question_deleted.connect(_on_answer_deleted.bind(answer_input_field))
	refreshAnswerNumbers()

# Make sure a certain number of answers exist
func ensureAnswerCount(count : int, deletable : bool = true) -> void:
	if question_answer_container == null:
		return
	while current_answer_count < count and current_answer_count < max_answer_count:
		addAnswerInputItem(deletable)

# Live answer fields in display order, optionally leaving one out (the one being deleted)
func getAnswerFields(excluded : QuestionAnswer = null) -> Array[QuestionAnswer]:
	var fields : Array[QuestionAnswer] = []
	if question_answer_container == null:
		return fields
	for child in question_answer_container.get_children():
		if child is QuestionAnswer and child != excluded and not child.is_queued_for_deletion():
			fields.append(child)
	return fields

# Renumber every field from its position, and keep the count in sync
func refreshAnswerNumbers(excluded : QuestionAnswer = null) -> void:
	var fields : Array[QuestionAnswer] = getAnswerFields(excluded)
	for i in range(fields.size()):
		fields[i].setQuestionNumber(i + 1) # Offset to turn into natural numbers
	current_answer_count = fields.size()

#endregion

#region SIGNALS

func _on_answer_deleted(deleted_field : QuestionAnswer) -> void:
	refreshAnswerNumbers(deleted_field)

#endregion
