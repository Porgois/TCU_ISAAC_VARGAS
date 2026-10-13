class_name QuestionCreationModal
extends Control

@export_group("Modal Title")
@export var modal_title : RichTextLabel = null
@export var modal_title_prefix : String = ""
@export var modal_title_sufix : String = ""
@export_group("")

@export var question_item_container : CenterContainer = null

#region QUESTION ITEM SCENES

var completion_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/completionQuestionItem.tscn")
var multiple_choice_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/multipleChoiceQuestionItem.tscn")
var match_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/matchQuestionItem.tscn")

#endregion

var associated_question_item : CustomQuestionItem = null

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
		var question_item = null # Maybe change this later to set specific type
		
		match associated_question_item.associated_question.type:
			Question.Type.MC:
				question_item = multiple_choice_item_scene.instantiate()
			Question.Type.COMPLETION:
				question_item = completion_item_scene.instantiate()
			_: # Match
				question_item = match_item_scene.instantiate()
		
		question_item_container.add_child(question_item)
	else:
		printerr("[CREATION MODAL] Error: Question item is not set!\n")
	
func saveQuestion():
	pass

func cancel():
	closeModal()

#endregion

#region SIGNALS

func _on_cancel_button_pressed() -> void:
	cancel()

#endregion
