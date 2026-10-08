class_name CustomQuestionItem
extends Control

@export var question_type_selector : QuestionTypeSelector = null

var general_modal_scene : PackedScene = preload("res://scenes/ui/customQuestion/generalModal.tscn")

var associated_question : Question = null
var associated_creation_modal : QuestionCreationModal = null

signal question_deleted(question_id : int)

func _ready() -> void:
	# Create question on start
	self.associated_question = Question.new()
	print("[CUSTOM QUESTION ITEM] Created a question!\n")
	
	# Connect type selected signal
	if question_type_selector != null:
		question_type_selector.type_selected.connect(setQuestionType)

#region MODAL

func createModal():
	# Instantiate question creation modal
	associated_creation_modal = general_modal_scene.instantiate()
	
	fillModal()
	pass
	
func openModal():
	pass

func closeModal():
	pass

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
	createModal()
	openModal()

func _on_delete_button_pressed() -> void:
	self.queue_free()
	question_deleted.emit(associated_question.question_id)

#endregion
