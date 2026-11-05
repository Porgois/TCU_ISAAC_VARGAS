class_name QuestionInputField
extends TextEdit

@export var text_edit : TextEdit = null
@export var question_number : RichTextLabel = null

#region INPUT TEXT

func setInputText(new_text : String = ""):
	if text_edit == null:
		printerr("[QUESTION INPUT] Error: Text edit not set!")
		return ""
	else: # Set text
		text_edit.text = new_text

func setPlaceholderText(new_text : String = ""):
	if text_edit == null:
		printerr("[QUESTION INPUT] Error: Text edit not set!")
		return ""
	else: # Set placeholder text
		text_edit.placeholder_text = new_text

func setQuestionNumber(number : int = -1):
	if question_number:
		question_number.text = str(number) + "."

func getInputText() -> String:
	if text_edit == null:
		printerr("[QUESTION INPUT] Error: Text edit not set!")
		return ""
	return text_edit.text

func printInputText():
	print("[QUESTION INPUT] Current text: ", getInputText())

#endregion
