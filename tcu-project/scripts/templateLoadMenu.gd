class_name TemplateLoad
extends Control

@export var menu_container : VBoxContainer
var default_template_path : String = "res://csvImports/Templates/"
var quiz_handler : QuizHandler = null

func _ready():
	quiz_handler = QuizHandler.new()
	loadTemplateButtons()

func loadTemplateButtons():
	# Make sure files being read are valid
	for file in getFilesInFolder(default_template_path):
		if file.get_extension().to_lower() == "csv":
			print("File named (", file , ") is valid!\n")
			createTemplateButton(file)

func getFilesInFolder(folder_path: String = "") -> PackedStringArray:
	var files = DirAccess.get_files_at(folder_path)
	return files

func createTemplateButton(file_name : String = ""):
	if file_name.is_empty():
		printerr("ERROR: No '.CSV' file found at: ", file_name)
	
	var template_button : Button = Button.new()
	template_button.text = file_name
	
	var full_path : String = default_template_path + file_name # Concatenate string names
	template_button.pressed.connect(onClickFunctionality.bind(full_path))
	menu_container.add_child(template_button)

func onClickFunctionality(file_name : String = ""):
	QuizManager.setQuiz(quiz_handler.loadQuiz(file_name))

#region BUTTON FUNCTIONS
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/MainMenu.tscn")

#endregion
