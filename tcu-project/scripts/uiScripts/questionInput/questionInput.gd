class_name QuestionInputField
extends Control

@export var text_edit : TextEdit = null

func getInputText() -> String:
	if text_edit == null:
		printerr("[QUESTION INPUT] Error: Text edit not set!")
		return ""
	return text_edit.text

func printInputText():
	print("[QUESTION INPUT] Current text: ", getInputText())
