class_name GenericPrompter
extends Control

# Emitted once the player submits their text.
signal input_saved(text: String)

@onready var input_field: LineEdit = $InputMenu/InputField
@onready var done_button: Button = $InputMenu/Done

func _ready() -> void:
	done_button.pressed.connect(_on_done_pressed)
	input_field.text_submitted.connect(_on_text_submitted)
	input_field.grab_focus()

func _on_done_pressed() -> void:
	_submit(input_field.text)

func _on_text_submitted(new_text: String) -> void:
	_submit(new_text)

func _submit(text: String) -> void:
	input_saved.emit(text)

# This is called before using the prompter again
func reset(placeholder_text: String = "") -> void:
	input_field.text = ""
	if placeholder_text != "":
		input_field.placeholder_text = placeholder_text
	input_field.grab_focus()
