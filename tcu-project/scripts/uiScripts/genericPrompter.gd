class_name GenericPrompter
extends Control

# Emitted once the player submits their text.
signal input_saved(text: String)

@export var no_response_wait_time : float = 5.0
@export var fadein_duration : float = 3.0
@export var guide_text : RichTextLabel = null
@export var guide_text_show_timer : Timer = null

@onready var input_field: LineEdit = $InputMenu/InputField
@onready var done_button: Button = $InputMenu/Done

func _ready() -> void:
	done_button.pressed.connect(_on_done_pressed)
	input_field.text_submitted.connect(_on_text_submitted)
	input_field.grab_focus()

# This is called before using the prompter again
func reset(placeholder_text: String = "") -> void:
	input_field.text = ""
	if placeholder_text != "":
		input_field.placeholder_text = placeholder_text
	input_field.grab_focus()

#region GUIDE TEXT
func enableGuideText(text : String = ""):
	# Set relevant guide text values (wait-time and visibility)
	guide_text_show_timer.wait_time = no_response_wait_time
	guide_text_show_timer.start()
	
	setGuideText(text)
	guide_text.modulate.a = 0.0 # Set to transparent
	guide_text.show()

func guideTextFadeIn():
	var tween = create_tween()
	tween.tween_property(guide_text, "modulate:a", 1.0, fadein_duration) # Fades in over n seconds

func setGuideText(new_text : String = ""):
	guide_text.text = new_text

#endregion

#region SIGNALS
func _on_done_pressed() -> void:
	_submit(input_field.text)

func _on_text_submitted(new_text: String) -> void:
	_submit(new_text)

func _submit(text: String) -> void:
	input_saved.emit(text)

# Wait until n seconds have passed before showing the guide text
func _on_guide_prompt_wait_timer_timeout() -> void:
	guideTextFadeIn()
#endregion
