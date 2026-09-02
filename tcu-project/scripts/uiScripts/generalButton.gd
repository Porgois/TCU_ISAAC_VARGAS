class_name GeneralButton
extends Button

@export var button_label : RichTextLabel

func setText(new_text : String = " "):
	if button_label:
		button_label.text = new_text
