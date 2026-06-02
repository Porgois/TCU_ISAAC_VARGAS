class_name TemplateLoad
extends Control

@export var menu_container: VBoxContainer
var default_template_path: String = "res://csvImports/Templates/"

func _ready() -> void:
	loadTemplateButtons()

func loadTemplateButtons() -> void:
	for file in getFilesInFolder(default_template_path):
		if file.get_extension().to_lower() == "csv":
			print("File named (%s) is valid!" % file)
			createTemplateButton(file)

func getFilesInFolder(folder_path: String = "") -> PackedStringArray:
	return DirAccess.get_files_at(folder_path)

func createTemplateButton(file_name: String = "") -> void:
	if file_name.is_empty():
		printerr("ERROR: No '.CSV' file found at: ", file_name)
		return

	var template_button := Button.new()
	template_button.text = file_name

	var full_path: String = default_template_path + file_name
	template_button.pressed.connect(_on_template_selected.bind(full_path))
	menu_container.add_child(template_button)

# Loads the quiz into 'Global' so it's ready when the dialogue scene starts
func _on_template_selected(full_path: String) -> void:
	var reader = FileReader.new()
	var raw = reader.loadCSVAsArray(full_path)
	var quiz = Quiz.new()
	quiz.quiz_name = full_path.get_file()
	quiz.questions = reader.textToQuestions(raw)
	QuizManager.setQuiz(quiz)

#region BUTTONS

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/MainMenu.tscn")

#endregion
