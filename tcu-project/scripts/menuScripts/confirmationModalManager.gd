class_name ConfirmModal
extends CanvasLayer

# Communication signal
signal answered(accepted : bool)

@export var title_label : RichTextLabel = null
@export var message_label : RichTextLabel = null
@export var ok_button : GeneralButton = null
@export var cancel_button : GeneralButton = null

func _ready() -> void:
	hide()
	ok_button.pressed.connect(answered.emit.bind(true))
	cancel_button.pressed.connect(answered.emit.bind(false))

func ask(title: String, message: String, ok_text := "Confirm", cancel_text := "Cancel") -> bool:
	setupText(title, message, ok_text, cancel_text)
	show()
	cancel_button.grab_focus()

	var accepted : bool = await answered
	hide()
	return accepted

func setupText(title : String, message: String, ok_text : String = "", cancel_text : String = ""):
	title_label.text = title
	message_label.text = message
	ok_button.setText(ok_text)
	cancel_button.setText(cancel_text)

func _unhandled_input(event : InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		answered.emit(false)
