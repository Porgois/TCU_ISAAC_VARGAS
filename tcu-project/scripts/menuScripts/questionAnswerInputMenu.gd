extends Control

@export var question_answer_container : VBoxContainer = null
@export var max_answer_count : int = 8 # Max number of answers that can be added

var text_input_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionAnswerInput.tscn")
var current_answer_count : int = 1

func addAnswerInputItem():
	var answer_input_field : QuestionAnswer = text_input_scene.instantiate()
	
	# Add to container
	if question_answer_container != null and current_answer_count < max_answer_count: # Up to max_answer_count - 1
		question_answer_container.add_child(answer_input_field)
		answer_input_field.question_deleted.connect(decreaseAnswerCount)
		current_answer_count += 1
	else:
		print("[QUESTION ANSWER MENU] Warning: Can't add more answers!\n") # Limit answer amount

func decreaseAnswerCount():
	current_answer_count = current_answer_count - 1

#region SIGNALS

func _on_button_pressed() -> void:
	addAnswerInputItem()

#endregion
