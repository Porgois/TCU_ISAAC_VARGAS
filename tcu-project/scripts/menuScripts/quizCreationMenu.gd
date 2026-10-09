class_name QuizCreationMenu
extends Control

@export var total_question_label : RichTextLabel
@export var total_question_label_preffix : String = "Total questions:"
@export var creator_container : VBoxContainer = null

var custom_question_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/customQuestionItem.tscn")

var question_count : int = 0

func _ready() -> void:
	setup()

#region SETUP

func setupItem(item : CustomQuestionItem) -> void:
	# Connect question deleted signal for existing question item children and set quiz control
	item.question_deleted.connect(deleteQuestionItem)
	item.quiz_control = self # Set self as quiz control item so that the question item knows \
	# what to set the modal parent to

func setupExistingItems():
	for child in creator_container.get_children():
		if child is CustomQuestionItem:
			setupItem(child)

func setup():
	# Get questions and setup signals
	setupExistingItems()
	refreshQuestions()

func refreshQuestions():
	var number : int = 1 # Start on one to make it more logical for human-reading
	for child in creator_container.get_children():
		if child is CustomQuestionItem and not child.is_queued_for_deletion():
			child.setQuestionNumber(str(number))
			number += 1
	
	question_count = number - 1 # Back to computer-numbering
	updateTotalQuestions() # Update number

#endregion

func addNewQuestionItem():
	var new_question_item : CustomQuestionItem = custom_question_item_scene.instantiate()
	setupItem(new_question_item)
	creator_container.add_child(new_question_item)
	
	refreshQuestions()

func deleteQuestionItem(question_id : int = -1) -> void:
	print("Deleted question with id: ", question_id)
	
	refreshQuestions()

func setupQuestionItemNumber(question_item : CustomQuestionItem = null, number : int = -1):
	question_item.setQuestionNumber(str(number))

#region TOTAL QUESTIONS & QUESTION NUMBER

# Calculate question numbers
func recalculateQuestionNumbers():
	var current_question_count : int = 0
	
	for child in creator_container.get_children():
		if child is CustomQuestionItem:
			child.setQuestionNumber(str(current_question_count))
			current_question_count += 1

# Change total question label based on the question container's children
func updateTotalQuestions() -> void:
	total_question_label.text = total_question_label_preffix + " " + str(question_count)

func getInitialQuestionCount():
	question_count = creator_container.get_child_count()
	updateTotalQuestions()

#endregion

#region SIGNALS

func _on_new_button_pressed() -> void:
	addNewQuestionItem()

#endregion
