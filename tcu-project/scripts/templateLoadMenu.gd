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
	createMenuFromFolder()
	#loadTemplateButtons()

#region TEMPLATE BUTTONS

# Load a template button for each file loaded
func loadTemplateButtons() -> void:
	for file in getFilesInFolder(default_template_path):
		if file.get_extension().to_lower() == "csv":
			print("File named (%s) is valid!" % file)
			createTemplateButton(file)

# Create a button for a template at a given path
func createTemplateButton(file_name: String = "") -> void:
	if file_name.is_empty():
		printerr("ERROR: No '.CSV' file found at: ", file_name)
		return

	var template_button : GeneralButton = general_button_scene.instantiate()
	template_button.button_label.text = file_name

	var full_path: String = default_template_path + file_name
	template_button.pressed.connect(_on_template_selected.bind(full_path))
	menu_container.add_child(template_button)

#endregion

#region FILE LOADING

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

#region HELPERS

# Get subfolders in a given folder
func getSubFoldersInFolder(folder_path : String = "") -> PackedStringArray:
	return DirAccess.get_directories_at(folder_path)

# Prints array
func printStringArray(string_array : PackedStringArray = []):
	var item_index : int = 0
	
	for item in string_array:
		print("Item #" + str(item_index) + ": ", string_array[item_index])
		
		item_index += 1

# Sort array based on string index termination
func sortByGradeSubstring(string_array : PackedStringArray = [], start_index : int = 0, length : int = 0) -> Array[String]:
	var result_array : Array[String] = []
	result_array.assign(string_array) # Populate with string array contents
	
	result_array.sort_custom(func(a : String, b: String): # 6 , 1
		var section_a = a.substr(start_index, length) # Extracts the grade/unit number
		var section_b = b.substr(start_index, length)
		
		return section_a < section_b
	)
	
	return result_array

# Get files in a given folder (Left empty assumes all extensions)
func getFilesInFolder(folder_path: String = "", extension : String = "") -> PackedStringArray:
	var all_files : PackedStringArray = DirAccess.get_files_at(folder_path)
	if extension != "": # Specific extension (filter)
		var filtered_files = Array(all_files).filter(
		func(file_name: String):
			return file_name.get_extension() == extension
		)
		
		return filtered_files
	else:
		return all_files

#endregion

#region GRADEMENU (TEST)

func createMenuFromFolder():
	# Grade folders
	var grade_folders_array : Array = Array(getSubFoldersInFolder("res://csvImports/templates/"))
	grade_folders_array = sortByGradeSubstring(grade_folders_array, 6, 1) # Sort
	
	# Main grade menu
	var grade_menu : GradeMenu = grade_menu_scene.instantiate()
	add_child(grade_menu)
	
	# Menus
	for grade in grade_folders_array: # Grade folders
		var m_menu : PopupMenu = grade_menu.createMenu(grade)
		grade_menu.add_child(m_menu)
		
		# Submenus
		var unit_folders_array : Array = Array(getSubFoldersInFolder("res://csvImports/templates/" + grade))
		unit_folders_array = sortByGradeSubstring(unit_folders_array, 5, 1) # Sort
		
		for unit in unit_folders_array: # Unit folders
			var s_menu : PopupMenu = grade_menu.createSubMenu(unit)
			grade_menu.addMenuItem(m_menu, s_menu)
			
			# Submenu items
			var files_array : Array = Array(getFilesInFolder("res://csvImports/templates/" + grade + "/" + unit, \
				"csv")) # '.csv' files only
			
			for file in files_array:
				grade_menu.addSubMenuItem(s_menu, file)

#endregion

#region SIGNALS
func _on_template_selected(full_path: String = "") -> void:
	loadFile(full_path)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/MainMenu.tscn")

func _on_browse_pressed() -> void:
	browseFile()

#endregion
