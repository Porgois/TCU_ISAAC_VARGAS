class_name QuizCreationMenu
extends Control

@export var total_question_label : RichTextLabel
@export var total_question_label_preffix : String = "Total questions:"
@export var creator_container : VBoxContainer = null

var custom_question_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/customQuestionItem.tscn")

func _ready() -> void:
	updateTotalQuestions()

func addNewQuestionItem():
	var new_question_item : CustomQuestionItem = custom_question_item_scene.instantiate()
	# Connect deletion signal
	new_question_item.question_deleted.connect(deleteQuestionItem)
	creator_container.add_child(new_question_item)
	
	updateTotalQuestions()

func deleteQuestionItem(question_id : int = -1):
	print("Deleted question with id: ", question_id)
	updateTotalQuestions()

#region TOTAL QUESTIONS

# Change total question label based on the question container's children
func updateTotalQuestions() -> void:
	var child_count : int = 0
	for child in creator_container.get_children():
		if not child.is_queued_for_deletion():
			child_count += 1
	total_question_label.text = total_question_label_preffix + " " + str(child_count)

#endregion

#region SIGNALS

func _on_new_button_pressed() -> void:
	addNewQuestionItem()

#endregion
