class_name TemplateLoad
extends Control

@export var menu_container: VBoxContainer
@export var loaded_prompt : Label
@export var options : Control

var general_button_scene : PackedScene = preload("res://scenes/ui/generalButton.tscn")
var grade_menu_scene : PackedScene = preload("res://scenes/menus/GradeMenu.tscn")
var default_template_path: String = "res://csvImports/Templates/"
var notification_time : float = 1.5

var menu_amount : int = 5
var sub_menu_amount : int = 3
var sub_menu_items : int = 6

func _ready() -> void:
	setup()
	#loadTemplateButtons()

#region GENERAL TEMPLATE MENU

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

	var template_button : GeneralButton = general_button_scene.instantiate()
	template_button.button_label.text = file_name

	var full_path: String = default_template_path + file_name
	template_button.pressed.connect(_on_template_selected.bind(full_path))
	menu_container.add_child(template_button)

# Loads the quiz into 'Global' so it's ready when the dialogue scene starts
func loadFile(full_path : String = ""):
	var reader = FileReader.new()
	var quiz = Quiz.new()
	quiz.quiz_name = full_path.get_file()
	quiz.questions = reader.loadCSVQuestions(full_path)
	QuizManager.setQuiz(quiz)
	
	loadedNotification(quiz.quiz_name)

# Displays the loaded notification
func loadedNotification(text : String = ""):
	options.hide()
	
	# Set prompt text
	loaded_prompt.show()
	loaded_prompt.text = "Template file '" + text + "' loaded succesfully!"
	
	await get_tree().create_timer(notification_time).timeout
	loaded_prompt.hide()
	options.show()

# Opens file dialog and loads the selected file path if valid
func browseFile():
	var file_path : String = ""
	
	var file_browser : FileBrowser = FileBrowser.new()
	get_tree().root.add_child(file_browser)
	
	file_path = file_browser.openFileBrowserWindow()
	
	if file_path != "":
		loadFile(file_path)

#endregion

#region GRADEMENU (TEST)

func setup():
	var index : int = 7
	
	var grade_menu : GradeMenu = grade_menu_scene.instantiate()
	add_child(grade_menu)
	
	# Menus
	for menu in menu_amount:
		var m_menu : PopupMenu = grade_menu.createMenu("Grade" + str(index))
		grade_menu.add_child(m_menu)
		
		index += 1
	
		# Submenus
		for sub_menu in sub_menu_amount:
			var s_menu : PopupMenu = grade_menu.createSubMenu("Unit")
			grade_menu.addMenuItem(m_menu, s_menu)
			
			# Submenu items
			for item in sub_menu_items:
				grade_menu.addSubMenuItem(s_menu, "Item")

#endregion

#region SIGNALS
func _on_template_selected(full_path: String = "") -> void:
	loadFile(full_path)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/MainMenu.tscn")

func _on_browse_pressed() -> void:
	browseFile()

#endregion
