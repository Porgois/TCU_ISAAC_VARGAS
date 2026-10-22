class_name QuestionAnswerMenu
extends Control

@export var question_answer_container : VBoxContainer = null
@export var max_answer_count : int = 8 # Max number of answers that can be added

var text_input_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionAnswerInput.tscn")
var current_answer_count : int = 0

# First answer already created
func _ready() -> void:
	addAnswerInputItem(false) # Not deletable (at least one answer)

#region COUNT

func addAnswerInputItem(is_deletable : bool = true):
	# Create and set values
	var answer_input_field : QuestionAnswer = text_input_scene.instantiate()
	answer_input_field.is_deletable = is_deletable
	
	# Add to container
	if question_answer_container != null and current_answer_count < max_answer_count: # Up to max_answer_count - 1
		question_answer_container.add_child(answer_input_field)
		answer_input_field.question_deleted.connect(decreaseAnswerCount)
		current_answer_count += 1
	else:
		print("[QUESTION ANSWER MENU] Warning: Can't add more answers!\n") # Limit answer amount

# Make sure a certain number of questions exist
func ensureAnswerCount(count : int, deletable : bool = true) -> void:
	if question_answer_container == null:
		return
	while current_answer_count < count and current_answer_count < max_answer_count:
		addAnswerInputItem(deletable)

func decreaseAnswerCount():
	current_answer_count = current_answer_count - 1

#endregion

#region SIGNALS

func _on_button_pressed() -> void:
	addAnswerInputItem()

#endregion
