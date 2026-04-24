class_name QuestionButton
extends Button

var question : Question

func set_question_values(question_text : String, is_right_answer : bool):
	if question == null:
		return
	
	# Set question values
	self.question.text = question_text
	self.question.is_correct = is_right_answer
	
	# Set button (self) values
	self.text = question.text

func _on_pressed() -> void:
	if (question.is_correct):
		print("RIGHT ANSWER")
	else:
		print("WRONG ANSWER")
