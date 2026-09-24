class_name SummaryItem
extends Node

@export var type_text : RichTextLabel
@export var question_text : RichTextLabel
@export var correct_text : RichTextLabel

# Sets item text values based on a given question
func setTextValues(question : Question = null):
	self.type_text.text = str(question.Type.keys()[question.type]).to_upper()
	self.question_text.text = question.question
	self.correct_text.text = str(question.was_answered_correctly)
