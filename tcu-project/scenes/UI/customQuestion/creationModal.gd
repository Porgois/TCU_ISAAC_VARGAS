class_name QuestionCreationModal
extends Control

@export_group("Modal Title")
@export var modal_title : RichTextLabel = null
@export var modal_title_prefix : String = ""
@export var modal_title_sufix : String = ""
@export_group("")

@export var question_item_container : CenterContainer = null

#region QUESTION ITEM SCENES

var completion_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/completionQuestionPrompter.tscn")
var multiple_choice_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/multipleChoiceQuestionPrompter.tscn")
var match_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/matchQuestionPrompter.tscn")

#endregion

var associated_question_item : CustomQuestionItem = null
var associated_question_prompter : GeneralQuestionPrompter = null 

func _ready() -> void:
	setQuestionItem()

#region MODAL

func setModalTitle(new_text : String = ""):
	if modal_title != null:
		modal_title.text = modal_title_prefix + " " + new_text + " " + modal_title_sufix

func closeModal():
	if self.visible: # Only hide for now
		self.hide()

func deleteModal():
	self.queue_free()

#endregion

#region MISC

func setQuestionItem():
	if associated_question_item != null:
		
		match associated_question_item.associated_question.type:
			Question.Type.MC:
				associated_question_prompter = multiple_choice_item_scene.instantiate()
			Question.Type.COMPLETION:
				associated_question_prompter = completion_item_scene.instantiate()
			_: # Match
				associated_question_prompter = match_item_scene.instantiate()
		
		associated_question_prompter.associated_creation_modal = self
		question_item_container.add_child(associated_question_prompter)
	else:
		printerr("[CREATION MODAL] Error: Question item is not set!\n")
	
func saveQuestion():
	if associated_question_prompter and associated_question_prompter.has_method("submitQuestion"):
		associated_question_prompter.submitQuestion(true) # Print questions for now
		associated_question_prompter.setQuestionPreviewText()

func cancel():
	closeModal()

#endregion

#region SIGNALS

func _on_cancel_button_pressed() -> void:
	cancel()

func _on_save_button_pressed() -> void:
	closeModal()
	saveQuestion()

#endregion
