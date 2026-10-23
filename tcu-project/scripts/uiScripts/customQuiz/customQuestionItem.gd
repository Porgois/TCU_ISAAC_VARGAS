class_name CustomQuestionItem
extends MarginContainer

@export var question_type_selector : QuestionTypeSelector = null
@export var question_number_label : RichTextLabel = null
@export var question_preview_label : RichTextLabel = null

var general_modal_scene : PackedScene = preload("res://scenes/ui/customQuestion/generalModal.tscn")

var modal_title_to_assign : String = ""
var associated_quiz_creation_menu : QuizCreationMenu = null

# Associated objects for communication (all are set from the other's script)
var associated_question : Question = null
var associated_creation_modal : QuestionCreationModal = null

# To determine wether or not edit button should open a modal
var type_set : bool = false

signal question_deleted(question_id : int)

func _ready() -> void:
	# Create question on start
	if associated_question == null:
		associated_question = Question.new()
	
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

#region LABELS

func setQuestionNumber(text : String = ""):
	if question_number_label != null:
		question_number_label.text = text + "."

func setQuestionPreview(text : String = ""):
	if question_preview_label != null:
		question_preview_label.text = text

#endregion

#region MODAL

# Load modal content based on existing question
func loadFromQuestion(question : Question) -> void:
	associated_question = question

	# CSV-loaded completion answers live in `blanks`; the editor uses `answers`.
	# Normalize, or FileReader.questionToRow() would keep saving the stale blanks.
	if question.type == Question.Type.COMPLETION:
		if question.answers.is_empty() and not question.blanks.is_empty():
			question.answers.assign(question.blanks[0].blank)
		question.blanks.clear()

	setQuestionPreview(question.question)
	if question_type_selector != null:
		question_type_selector.setTypeSilently(question.type)
	type_set = true
	
# Check if the modal is not created, it is just open it
func checkModalRequirements():
	if type_set: # Only do something if a question type has been selected
		if associated_creation_modal != null: # Modal exists
			openModal()
		else: # Modal does not exist
			createModal()

func setModalTitle():
	if associated_creation_modal:
		associated_creation_modal.setModalTitle(modal_title_to_assign)

# Creates a modal fill based on the question type
func checkModalType():
	match associated_question.type:
		Question.Type.MC:
			modal_title_to_assign = "Multiple Choice"
			print("The question is Multiple Choice!\n")
		Question.Type.COMPLETION:
			modal_title_to_assign = "Completion"
			print("The question is Completion!\n")
		_: # Default (must be match)
			modal_title_to_assign = "Match"
			print("The question is Match!\n")

# Creates modal based on question type
func createModal():
	# Check modal type
	checkModalType()

	# Instantiate question creation modal and associate values
	associated_creation_modal = general_modal_scene.instantiate()
	associated_creation_modal.associated_question_item = self # Associated self with the modals question
	associated_creation_modal.hide()
	setModalTitle()
	
	# Add modal to quiz control node
	if associated_quiz_creation_menu != null:
		associated_quiz_creation_menu.add_child(associated_creation_modal)
	
	fillModal()
	openModal()

func openModal():
	if associated_creation_modal != null:
		associated_creation_modal.show()

func closeModal():
	if associated_creation_modal != null:
		associated_creation_modal.hide()

func fillModal():
	if associated_creation_modal == null:
		return
	
	var prompter : GeneralQuestionPrompter = associated_creation_modal.associated_question_prompter
	if prompter != null:
		prompter.loadFromQuestion(associated_question)

#endregion

#region QUESTION METHODS

func setQuestionId(id : int = -1):
	associated_question.question_id = id
	
func setQuestionType(question_type : Question.Type = Question.Type.MC):
	associated_question.type = question_type
	type_set = true # The modal can now be created
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

# Returns the question item's associated Question object
func getAssociatedQuestion() -> Question:
	var result : Question = null
	if associated_question != null:
		result = associated_question
	else:
		printerr("[CUSTOM QUESTION ITEM] Error: The associated question is empty!\n")
	return result

#endregion

#region SIGNALS

func _on_edit_button_pressed() -> void:
	checkModalRequirements()

func _on_delete_button_pressed() -> void:
	delete()

#endregion
