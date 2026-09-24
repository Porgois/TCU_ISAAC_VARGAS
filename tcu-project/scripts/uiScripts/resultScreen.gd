class_name ResultScreen
extends Node

signal continueToCompletionImage

var summary_item_scene : PackedScene = preload("res://scenes/ui/resultSummaryScreen/summaryItem.tscn")
@export var results_container : BoxContainer

# Creates a summaryItem and adds it to the results container
func appendItemQuestions(questions : Array[Question] = []):
	for question in questions:
		# Create summary_item and set values
		var new_summary_item : SummaryItem = summary_item_scene.instantiate()
		new_summary_item.setTextValues(question)
		results_container.add_child(new_summary_item)

func _on_continue_button_pressed() -> void:
	continueToCompletionImage.emit()
