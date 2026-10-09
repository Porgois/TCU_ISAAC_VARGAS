class_name CustomQuestionItem
extends Control

@export var question_type_selector : QuestionTypeSelector = null
@export var question_number_label : RichTextLabel = null

var general_modal_scene : PackedScene = preload("res://scenes/ui/customQuestion/generalModal.tscn")

var associated_question : Question = null
var associated_creation_modal : QuestionCreationModal = null
var quiz_control : QuizCreationMenu = null

signal question_deleted(question_id : int)

func _ready() -> void:
	# Create question on start
	self.associated_question = Question.new()
	print("[CUSTOM QUESTION ITEM] Created a question!\n")
	
	# Connect type selected signal
	if question_type_selector != null:
		question_type_selector.type_selected.connect(setQuestionType)

func delete():
	if is_queued_for_deletion():
		return
	
	# Modal exists?, delete it
	if associated_creation_modal != null:
		associated_creation_modal.queue_free()
	
	# Emit deletion signal, then delete
	queue_free()
	question_deleted.emit(associated_question.question_id)

func setQuestionNumber(text : String = ""):
	if question_number_label != null:
		question_number_label.text = text + "."
	
#region MODAL

# Check if the modal is not created, it is just open it
func checkModalRequirements():
	if associated_creation_modal != null: # Modal exists
		openModal()
	else: # Modal does not exist
		createModal()

func createModal():
	# Instantiate question creation modal and associate values
	associated_creation_modal = general_modal_scene.instantiate()
	associated_creation_modal.associated_question_item = self # Associated self with the modals question
	associated_creation_modal.hide()
	
	# Add modal to quiz control node
	if quiz_control != null:
		quiz_control.add_child(associated_creation_modal)
	
	fillModal()
	openModal()

func openModal():
	if associated_creation_modal != null:
		associated_creation_modal.show()

func closeModal():
	if associated_creation_modal != null:
		associated_creation_modal.hide()

func fillModal():
	pass

#endregion

#region QUESTION METHODS

func setQuestionId(id : int = -1):
	associated_question.question_id = id
	
func setQuestionType(question_type : Question.Type = Question.Type.MC):
	associated_question.type = question_type
	print("[CUSTOM QUESTION ITEM] Set question type to: ", Question.Type.keys()[question_type])

func addQuestionOption(option_text : String = ""):
	associated_question.options.push_back(option_text)
	print("[CUSTOM QUESTION ITEM] Added question option: ", option_text, "\n")

func setQuestionText(new_question_text : String = ""):
	associated_question.question = new_question_text
	print("[CUSTOM QUESTION ITEM] Set question text to: ", new_question_text, ".\n")

func addQuestionAnswer(answer_text : String = ""):
	associated_question.answers.push_back(answer_text)
	print("[CUSTOM QUESTION ITEM] Added question answer: ", answer_text, ".\n")

func removeQuestionAnswer(answer_index : int = -1):
	if answer_index >= 0 and answer_index < associated_question.answers.size(): # Exists in array
		print("[CUSTOM QUESTION ITEM] Removed answer at index: ", answer_index, \
			" (", associated_question.answers[answer_index], ").\n") # Print, then delete (needs deleted value)
		associated_question.answers.remove_at(answer_index)

#endregion

#region SIGNALS

func _on_edit_button_pressed() -> void:
	checkModalRequirements()

func _on_delete_button_pressed() -> void:
	delete()

#endregion
