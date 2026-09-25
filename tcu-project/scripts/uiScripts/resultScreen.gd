class_name ResultScreen
extends Node

signal continueToCompletionImage

@export var results_container : BoxContainer

var summary_item_scene : PackedScene = preload("res://scenes/ui/resultSummaryScreen/summaryItem.tscn")
var horizontal_separator_scene : PackedScene = preload("res://scenes/ui/generalHSeparator.tscn")

# Creates a summaryItem and adds it to the results container
func appendItemQuestions(questions : Array[Question] = []):
	for question in questions:
		# Create summary_item and set values
		var new_summary_item : SummaryItem = summary_item_scene.instantiate()
		new_summary_item.setTextValues(question)
		results_container.add_child(new_summary_item)
		
		# Create horizontal separator
		addHorizontalSeparator()

# Creates a custom horizontal separator for readabilities' sake
func addHorizontalSeparator():
	# Instantiate horizontal separator
	var new_h_separator : HSeparator = horizontal_separator_scene.instantiate()
	results_container.add_child(new_h_separator)

func _on_continue_button_pressed() -> void:
	continueToCompletionImage.emit()
